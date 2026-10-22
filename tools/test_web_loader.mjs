// Run against the patched, exported Godot bootstrap, not a duplicate downloader.
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import vm from 'node:vm';

const engine = readFileSync(process.argv[2], 'utf8');
const preloaderSource = engine.slice(engine.indexOf('const Preloader ='), engine.indexOf('const InternalConfig ='));
assert.ok(preloaderSource.startsWith('const Preloader ='));

function loader(fetch) {
  const timers = new Map();
  let id = 0;
  const context = vm.createContext({
    fetch, Response, ReadableStream, AbortController, ArrayBuffer, Uint8Array,
    setTimeout(callback, delay) {
      if (delay === 1000) {
        queueMicrotask(callback);
        return ++id;
      }
      const handle = ++id;
      timers.set(handle, callback);
      return handle;
    },
    clearTimeout(handle) { timers.delete(handle); },
    requestAnimationFrame() {},
  });
  vm.runInContext(`${preloaderSource}\nglobalThis.preloader = new Preloader();`, context);
  return {
    preloader: context.preloader, timers,
    expire() {
      for (const [handle, callback] of [...timers]) {
        timers.delete(handle);
        callback();
      }
    },
  };
}

const turn = () => new Promise(resolve => setImmediate(resolve));
const payload = new Uint8Array([1, 2, 3, 4]);

for (const raw of [false, true]) {
  const test = loader(async () => new Response(payload));
  const value = await test.preloader.loadPromise('game.bin', 4, raw);
  const bytes = raw ? await value.arrayBuffer() : value;
  assert.deepEqual(new Uint8Array(bytes), payload);
  assert.equal(test.timers.size, 0, 'successful downloads clear their timers');
}

// A stalled connection retries four times, bypasses stale cache and then rejects.
{
  const attempts = [];
  const test = loader((file, options) => {
    attempts.push(options);
    return new Promise(() => {});
  });
  const result = test.preloader.loadPromise('game.wasm', 4, true).then(
    () => assert.fail('stalled connection resolved'), error => error,
  );
  for (let i = 0; i < 4; i++) {
    test.expire();
    await turn();
  }
  assert.match((await result).message, /Network connection timed out/);
  assert.equal(attempts.length, 4);
  assert.equal(attempts[0].cache, 'default');
  assert.ok(attempts.slice(1).every(options => options.cache === 'reload'));
  assert.ok(attempts.every(options => options.signal.aborted));
  assert.equal(test.timers.size, 0);
}

// Headers can arrive successfully and then the response body can stop forever.
for (const raw of [false, true]) {
  let attempts = 0;
  const test = loader(async () => {
    attempts++;
    return new Response(new ReadableStream({ start() {} }));
  });
  const result = (async () => {
    try {
      const value = await test.preloader.loadPromise('game.bin', 4, raw);
      if (raw) await value.arrayBuffer();
      assert.fail('stalled body resolved');
    } catch (error) { return error; }
  })();
  await turn();
  for (let i = 0; i < (raw ? 1 : 4); i++) {
    test.expire();
    await turn();
  }
  assert.match((await result).message, /Network download stalled/);
  assert.equal(attempts, raw ? 1 : 4);
  assert.equal(test.timers.size, 0);
}

// A broken stream must reject the pack read, allowing the existing retry loop.
{
  let attempts = 0;
  const test = loader(async () => {
    if (++attempts === 1) {
      return new Response(new ReadableStream({
        start(controller) { controller.error(new Error('connection reset')); },
      }));
    }
    return new Response(payload);
  });
  assert.deepEqual(new Uint8Array(await test.preloader.loadPromise('game.pck', 4)), payload);
  assert.equal(attempts, 2);
  assert.equal(test.timers.size, 0);
}

// A slow but active transfer re-arms the timer whenever bytes actually arrive.
{
  let stream;
  const test = loader(async () => new Response(new ReadableStream({
    start(controller) { stream = controller; },
  })));
  const result = test.preloader.loadPromise('game.pck', 4);
  await turn();
  let timer = [...test.timers.keys()][0];
  for (const byte of payload) {
    stream.enqueue(new Uint8Array([byte]));
    await turn();
    const next = [...test.timers.keys()][0];
    assert.notEqual(timer, next);
    assert.equal(test.timers.size, 1);
    timer = next;
  }
  stream.close();
  assert.deepEqual(new Uint8Array(await result), payload);
  assert.equal(test.timers.size, 0);
}

// A header failure and an initialization/compilation failure must reach startGame.
const initStart = engine.indexOf('function doInit(promise) {');
const initEnd = engine.indexOf('preloader.setProgressFunc', initStart);
for (const phase of ['download', 'compile', 'filesystem', 'filesystem-result', 'ready']) {
  const failure = new Error(phase);
  const me = { config: {
    getModuleConfig: () => ({}), persistentPaths: ['/userfs'], unloadAfterInit: true,
  } };
  const module = { initFS: () => phase === 'filesystem'
    ? Promise.reject(failure) : Promise.resolve(phase === 'filesystem-result' ? failure : null) };
  const context = vm.createContext({
    Response, me, loadPath: 'game', Engine: { unload() {} },
    Godot: () => phase === 'compile' ? Promise.reject(failure) : Promise.resolve(module),
  });
  vm.runInContext(`${engine.slice(initStart, initEnd)}\nglobalThis.initialize = doInit;`, context);
  const result = context.initialize(phase === 'download' ? Promise.reject(failure) : Promise.resolve(new Response(payload)));
  if (phase === 'ready') {
    await result;
    assert.equal(me.rtenv, module);
  } else {
    await assert.rejects(result, error => error === failure);
  }
}

// Exercise the real shell with a zero/small progress callback and startup failure.
const shell = readFileSync(new URL('../web/loading.html', import.meta.url), 'utf8');
const source = shell.slice(shell.lastIndexOf('<script>') + 8, shell.lastIndexOf('</script>'))
  .replace('$GODOT_CONFIG', JSON.stringify({ executable: 'game', focusCanvas: true }))
  .replace('$GODOT_THREADS_ENABLED', 'false').replace('$GODOT_URL', 'game.js');
const elements = new Map();
function element() { return { textContent: '', hidden: false, setAttribute() {}, removeAttribute() {}, addEventListener() {}, focus() {} }; }
let script;
let startup;
let rejectStartup;
let scriptDeadline;
const errorHandlers = new Map();
const context = vm.createContext({
  document: {
    title: 'The Grand Tour', documentElement: {},
    getElementById(id) { if (!elements.has(id)) elements.set(id, element()); return elements.get(id); },
    createElement() { script = element(); script.addEventListener = (name, callback) => { script[name] = callback; }; return script; },
    head: { appendChild() {} },
  },
  navigator: { language: 'zh-CN' }, performance: { now: () => 0 },
  window: { addEventListener(name, callback) { errorHandlers.set(name, callback); }, removeEventListener() {} },
  console: { error() {} }, setInterval() {}, clearInterval() {},
  setTimeout(callback) { scriptDeadline = callback; }, clearTimeout() {},
  Engine: Object.assign(class {
    startGame(options) { startup = options; return new Promise((resolve, reject) => { rejectStartup = reject; }); }
  }, { getMissingFeatures: () => [] }),
});
vm.runInContext(source, context);
script.load();
startup.onProgress(0, 64 * 1048576);
assert.match(elements.get('loading-status').textContent, /正在连接资源服务器/);
assert.doesNotMatch(elements.get('loading-status').textContent, /^0%$/);
startup.onProgress(64 * 1024, 64 * 1048576);
assert.match(elements.get('loading-status').textContent, /0\.1%.*0\.1 \/ 64\.0 MiB/);
startup.onProgress(64 * 1048576, 64 * 1048576);
assert.match(elements.get('loading-status').textContent, /正在启动游戏/);
assert.equal(elements.get('loading').hidden, false, 'download completion is not game readiness');
rejectStartup(new Error('Network connection timed out: game.wasm'));
await turn();
assert.equal(elements.get('loading-retry').hidden, false);
assert.equal(elements.get('loading-progress').hidden, true);
assert.match(elements.get('loading-notice').textContent, /连接超时.*network/);
assert.match(elements.get('loading-status').textContent, /加载失败/);

// Loading the engine script can itself hang before any progress callback exists.
elements.clear();
vm.runInContext(source, context);
scriptDeadline();
assert.equal(elements.get('loading-retry').hidden, false);
assert.match(elements.get('loading-notice').textContent, /engine script/);

console.log('Web loader regressions passed: downloads, stalled connections/bodies, retries, active streams, initialization and real shell progress.');
