#!/usr/bin/env python3
"""Bound stalled Godot Web downloads and propagate stream/init failures.

Patch only the exported 4.7.2 bootstrap, leaving the installed template intact.
Fail closed if a template upgrade changes either of the expected functions.
"""
from pathlib import Path
import argparse


DOWNLOADS = r'''function getTrackedResponse(response, load_status, abort, file) {
		const reader = response.body.getReader();
		let timer;
		let finished = false;
		const clear = () => clearTimeout(timer);
		return new Response(new ReadableStream({
			start(controller) {
				const fail = (error) => {
					if (finished) return;
					finished = true;
					clear();
					controller.error(error);
					abort.abort();
					reader.cancel(error).catch(() => {});
				};
				const arm = () => {
					clear();
					timer = setTimeout(() => fail(new Error(`Network download stalled: ${file}`)), 30000);
				};
				const read = async () => {
					try {
						arm();
						while (!finished) {
							const result = await reader.read();
							if (finished) return;
							if (result.value && result.value.length) {
								controller.enqueue(result.value);
								load_status.loaded += result.value.length;
								arm();
							}
							if (result.done) {
								finished = true;
								clear();
								load_status.done = true;
								controller.close();
							}
						}
					} catch (error) {
						fail(error);
					}
				};
				read();
			},
			cancel(reason) {
				finished = true;
				clear();
				abort.abort();
				return reader.cancel(reason);
			},
		}), { headers: response.headers });
	}

	async function loadFetch(file, tracker, fileSize, raw) {
		// Keep the previous count while reconnecting so the progress display survives retries.
		const retrying = Object.prototype.hasOwnProperty.call(tracker, file);
		const previous = retrying ? tracker[file].loaded : 0;
		const stat = { total: fileSize || 0, loaded: previous, done: false };
		tracker[file] = stat;
		const abort = new AbortController();
		let timer;
		try {
			const response = await Promise.race([
				fetch(file, { signal: abort.signal, cache: retrying ? 'reload' : 'default' }),
				new Promise((resolve, reject) => {
					timer = setTimeout(() => {
						reject(new Error(`Network connection timed out: ${file}`));
						abort.abort();
					}, 30000);
				}),
			]);
			clearTimeout(timer);
			if (!response.ok) throw new Error(`HTTP ${response.status}: failed loading file '${file}'`);
			if (!response.body) throw new Error(`Network response has no body: ${file}`);
			stat.loaded = 0;
			const tracked = getTrackedResponse(response, stat, abort, file);
			return raw ? tracked : await tracked.arrayBuffer();
		} catch (error) {
			abort.abort();
			throw error;
		} finally {
			clearTimeout(timer);
		}
	}

	'''

INITIALIZE = '''function doInit(promise) {
					return promise.then(function (response) {
						const cloned = new Response(response.clone().body, { 'headers': [['content-type', 'application/wasm']] });
						return Godot(me.config.getModuleConfig(loadPath, cloned)).then(function (module) {
							return module['initFS'](me.config.persistentPaths).then(function (err) {
								if (err) throw err;
								me.rtenv = module;
								if (me.config.unloadAfterInit) Engine.unload();
							});
						});
					});
				}
				'''


def patch(source: str) -> str:
    start = source.index("function getTrackedResponse(response, load_status) {")
    end = source.index("function retry(func, attempts = 1) {", start)
    original = source[start:end]
    if "return fetch(file).then" not in original or "onloadprogress(reader, controller).then" not in original:
        raise ValueError("Unexpected Godot preloader; review the template before patching")
    source = source[:start] + DOWNLOADS + source[end:]
    start = source.index("function doInit(promise) {")
    end = source.index("preloader.setProgressFunc", start)
    if "new Promise(function (resolve, reject)" not in source[start:end]:
        raise ValueError("Unexpected Godot initializer; review the template before patching")
    return source[:start] + INITIALIZE + source[end:]


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("engine", type=Path)
    args = parser.parse_args()
    source = args.engine.read_text(encoding="utf-8")
    args.engine.write_text(patch(source), encoding="utf-8")
    print(f"[web-loader] Added connection/stream timeouts and failure propagation: {args.engine.name}")


if __name__ == "__main__":
    main()
