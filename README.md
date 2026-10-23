# The Grand Tour · 互动旅行画册

一款 Godot 2D 手绘旅行探索游戏。打开画册，选择西贡漫步（12 站）、吴哥寻迹（26 站）、大同及周边（7 站），或从兰州出发的河西走廊（20 站）。你的伙伴 Archie（奶油白毛色、蓝灰耳尖、橙色领巾的小家伙）会在明确的地面范围内陪你漫步；其他视角可静静观景。欣赏建筑、阅读介绍，并在中央邮局寄出第一张明信片。

**[点击这里直接玩网页版](https://huizhixu.github.io/grandtour/)** · 建议使用电脑浏览器，首次打开需要加载游戏资源。明信片进度保存在当前浏览器，清除网站数据会清除进度。

## 当前玩法

- 点击空地行走，再次点击可改道；点击人物、物件或门廊会先走近再互动。
- 邮局外广场与内部大厅可以往返，角色只能在明确标出的地面范围内行走；建筑、围栏和立柱后的点击会调整到附近可达地面。
- **寄出西贡的第一张明信片**：向摄影师领取 → 阅读建筑介绍牌 → 到大厅右侧书写台选择三种寄语之一 → 回到旧邮筒确认投递。
- **其他 64 个景点**：只保留「景点介绍」，点击即可阅读。保留风景、地面漫步及已有视角切换，不设置观察选择、记录确认或纪念任务。
- 明信片进度自动保存在当前设备。回到街区入口会保留进度。
- `Esc` 关闭对话或暂停；悬停显示可互动物件名称，地面菱形标记显示目的地。

## 旅行路线

启动时打开四本旅程的封面画册；右上角「旅行画册」可随时返回。选一册后打开该旅程的缩略图路线册，自由选站或继续上次停留的位置，每册独立保存续游点。右下角「下一站」按当前路线前进，末站返回本册路线；暂停后的回到入口也回到当前旅程的起点。路线册中的 ✓ 仅用于中央邮局已完成的明信片任务，其他景点不设任务进度。

- **河西走廊 · 从兰州出发（20 站）**：兰州（甘肃省博物馆、中山桥、白塔山、黄河母亲雕塑）→ 武威（雷台汉墓、武威文庙、天梯山石窟、武威市博物馆）→ 张掖（七彩丹霞、平山湖大峡谷、马蹄寺石窟、张掖大佛寺）→ 嘉峪关（关城、悬壁长城、长城第一墩）→ 敦煌（莫高窟、鸣沙山·月牙泉、玉门关、阳关、雅丹）。路线册提供五个城市标签，「下一站」跨城依次前进，每册独立保存续游位置。兰州为出发站；本册 20 幅采用官方实景照片的实际视角，以观景和景点介绍为主。
- **经典建筑与城市漫步**：独立宫 → 红教堂（圣母大教堂）→ 中央邮局 → 阮文平书街 → 市政厅 → 歌剧院 → 阮惠步行街 → 咖啡公寓。
- **市场、艺术与历史**：滨城市场 → 胡志明市美术馆 → 粉红教堂 → 战争遗迹博物馆。粉红教堂前后显示乘车转场提示；也可把博物馆与独立宫放在一起自由参观。
- **大同及周边 · 晋北古建（7 站）**：大同古城墙 → 华严寺 → 善化寺 → 九龙壁 → 云冈石窟 → 悬空寺 → 应县木塔。应县木塔位于朔州市应县，为本册周边延伸站；善化寺本幅选取西园池畔视角。云冈和九龙壁支持前方铺地漫步，其他五幅为观景全景。画风采用用户确认的悬空寺精修版，实景来源及新增绘制提示词见 `docs/datong-art/production-v1.json`；悬空寺提示词见 `docs/datong-art/style-study-v2.json`。通过 `python3 tools/prepare_datong_art.py` 生成运行图。
- **暹粒 · 吴哥（已开放 26 站）**：通王城南门 → 巴戎寺 → 巴方寺 → 空中宫殿 → 战象台 → 癞王台 → 王宫遗址 → 胜利门 → 周萨神庙 → 托玛侬神庙 → 茶胶寺 → 塔布茏寺 → 小吴哥 → 巴肯山 → 班黛喀蒂 → 圣剑寺 → 龙蟠水池 → 塔逊庙 → 东梅棚 → 比粒寺 → 豆蔻寺 → 女王宫 → 崩密列 → 神牛寺 → 巴空寺 → 洞里萨湖。每站均可直接阅读景点介绍。后续尚未确认的景点不显示为空白站点。用户已取消小吴哥日出视角与皇家浴池；当前范围内的 26 个独立景点已全部接入。

塔布茏寺与小吴哥各有 4 个实景视角，通过上方「切换视角」打开缩略图菜单。已有多视角与地面边界继续保留；观景视角可直接阅读介绍，有地面视角的景点也可返回漫步，并恢复本次游玩中的角色位置。巴肯山、崩密列与洞里萨湖保持纯观景。

暹粒 26 站、44 幅现有视角已统一为中央邮局的细线水彩风格，由用户授权全部生成并替换。画风固定参考邮局，建筑依据 APSARA 官方照片及保护报告；巴肯山近景参考世界建筑文物保护基金会（WMF）的保护现场照片。洞里萨湖高脚屋以 UNESCO 官方照片为建筑依据，保留用户确认的疏朗村落构图。全部画面均为依据官方实景创作的 AI 插画，并非官方原图或测绘复原。水池、残墙和建筑不属于行走区域，互动点按每幅画面单独设置。官方来源、完整提示词和文件校验值见 `docs/siem-reap-art/postoffice-style-rollout.json`，运行图通过 `python3 tools/prepare_angkor_art.py` 编码为 1600 × 900、质量 91 的 JPEG。

2026-10-20 玩法简化：除中央邮局外，所有景点统一为一个「景点介绍」入口。旧存档中的观察、记录和独立宫纪念数据保留兼容，不再显示为待办或完成度。中央邮局的摄影师、建筑介绍牌、室内书写和邮筒投递流程继续保留。

新增景点以外部空间为主；红教堂、市政厅和歌剧院不提供内部参观。绘本背景不代表现实中的即时修缮、商家和开放状态。转场表达站点之间的旅行，不是按比例连续的城市地图。新美术完整提示词与文件路径见 `docs/tour-art-prompts.json`，内容与地标参考见 `docs/tour-routes.md`。

2026-10-19 全面回归：38 个景点的路线与互动、全部已接入视角、存档恢复与旧任务兼容已检查；修复转场提示遮挡视角按钮，以及部分记录标签与角色或底部提示重叠。七套测试共 2,551 项通过，Web 导出包在隔离目录验证。旧模板测试与原生截图工具已适配当前旅行游戏，CI 增加基础测试与导出包检查。

河西走廊每一幅插画均将官方实景图作为建筑与地貌依据，现有画风图只用于线条和水彩风格参考。原图与来源页保存在 `docs/hexi-art/references/`，逐站来源、图片校验值及完整提示词见 `docs/hexi-art/production-v1.json`。不凭文字重建地标、不为行走虚构平台或道路；本批的水面、陡坡、台阶与遗址均按原图保留。运行图通过 `python3 tools/prepare_hexi_art.py` 编码。

## 本地运行与验证

使用 Godot 4.7.2 打开 `project.godot` 并运行主场景；也可以使用命令行：

```sh
godot --editor --path .
godot --path .
```

首次运行命令行测试前先导入资源：

```sh
godot --headless --editor --import --path .
godot --headless --path . res://test/test_suite.tscn
godot --headless --path . --script res://test/exploration_suite.gd
godot --headless --path . --script res://test/postcard_suite.gd
godot --headless --path . --script res://test/walkable_ground_suite.gd
godot --headless --path . --script res://test/archie_animation_suite.gd
godot --headless --path . --script res://test/palace_suite.gd
godot --headless --path . --script res://test/tour_suite.gd
```

`archie_animation_suite.gd` 检查四方向完整跑动循环、转向步态连续、待机眨眼与暂停，同时确认画面弹跳不会移动碰撞体。

`palace_suite.gd` 检查独立宫介绍、地面边界，以及返回邮局后的任务恢复。`tour_suite.gd` 遍历全部 65 个路线入口及现有视角，检查只保留景点介绍、无探索任务、弹窗布局、暂停和旧存档兼容。

`postcard_suite.gd` 覆盖八方向移动、改道与暂停、完整任务、取消投递、存档恢复和对话框布局。设置 `GRANDTOUR_CAPTURE_DIR` 并使用真实图形渲染运行该测试，可保存场景、方向动画与任务截图；截图模式不能使用 `--headless`。

网页导出使用项目中的 `Web` 预设，需要对应 Godot 导出模板。模板自带的 `npm` 命令依赖 Manus Game runtime；直接使用 Godot 运行和测试无需该 runtime。

安装 Web 导出模板后执行 `bash tools/export_web.sh`，输出位于 `dist/web/`。仓库推送到 `main` 后，GitHub Actions 会自动导出、验证并发布到 GitHub Pages。

---

## 原始模板参考

以下内容保留初始化模板的历史说明；其中迷宫玩法和模板交付记录不代表当前的西贡探索版本。

This versioned source is owned by the Webdev Addon. Use the installed Game workflow for initialization, preview, release and publishing. Matching gameplay source: template-provenance.json. Existing projects are never overwritten by a new starter.

For online multiplayer, read [the shared service guide](docs/game-multiplayer.md).

## Shared game-development workflow

Applies to Max effort, not `fast_prototype`; Fast uses its dedicated section instead. Keep edits scoped and
preserve explicit constraints.

### Preserve the selected template
Extend the initialized project and keep its working simulation, controls, saves and delivery. Integrate supplied
games into that project. The first Preview must show the requested game, not a renamed demo; replace the Generic
maze gameplay unless a maze was requested.

### First-checkpoint completion contract
Deliver the requested goal, actions and outcome loop with understandable controls and feedback, recovery or replay
where it fits, coherent readable visuals, the necessary start, pause and results screens, and any requested
deliverable. Match run length and content to the brief; there is no minimum playtime, campaign, extra mode or screen
quota. Prioritize gameplay, broken resources, responsiveness and visible defects, and stop when the requested
experience works. Add art, audio or polish only for a concrete benefit. Leaderboards, new Tweak controls and extra
languages are optional; required Share OG and explicit media, concept or feature requests are not.
Default to desktop. Add or test touch controls, portrait layouts or mobile-browser support only when the user asks.
Sharing a Web link is not a mobile request. Keep inherited controls working without expanding mobile coverage.

Choose the [delivery scope](game-delivery.md#delivery-scope-and-stopping-boundary) from the request. Ordinary managed
delivery is check → save-release.mjs → applicable check --pack → push the exact SHA and confirm the checkpoint.
Documentation-only edits need no engine boot. Do not add audit reports, speculative test suites, a separate
self-review phase or duplicate validation workers.

### Ownership boundaries
Keep flow, authoritative simulation and scoring, input, entities, tuning, presentation and persistence in their
existing owners; cosmetics never decide collisions or rewards. Offline authority stays in Godot and online authority
on the dedicated server. WASD is reserved for player movement or camera panning, never abilities or menu actions;
leave it unbound when nothing moves, and update remapping, tutorials and hints when replacing conflicting shortcuts.

### Gameplay feedback and optional polish
Make actions, damage, rewards and outcomes readable with the simplest fitting cues. Reuse existing feedback and
add effects only where they improve readability or the requested feel; no particle set, reward flights, screen shake
or animated counters are required. Keep overlays input-transparent and cosmetics independent of simulation, and
preserve reduced-motion settings.

### Tutorial content boundary
Explain the necessary goals, controls and rules briefly in the game's language; a short start-screen hint is enough
for simple games. A staged tutorial needs a working Skip that releases input and pause locks and remembers the dismissal. Keep implementation
values and Tweak controls out of player instructions.

### Optional local leaderboard
Add local standings only when requested or integral to scoring and replay, and keep a useful existing one; changes
keep bounded records, once-only terminal submissions and deterministic ties. Online
rankings need an explicit request and the installed leaderboards guide; never provision a backend for an offline
game by default.

### Native verification
Reuse existing checks for changed gameplay, input, audio, saves, localization or tuning. For visual questions,
capture with the real renderer (`get_viewport().get_texture().get_image()` and `Image.save_png()`); headless Dummy
rendering proves nothing visual. Do not drive the Preview with browser automation, screenshots or self-tests unless
the user asks for browser debugging; use logs and report Web input, audio and layout as pending user acceptance.

### Concept work by request
Concepts are conditional, not a routine production step. Follow the Blueprint's recorded mockup choice and do not
offer a second concept workflow when the direction is already clear. For an explicit request, produce distinct,
coherent interpretations of the brief and keep the selected identity through revisions. The Game Concept Design flow
needs exactly three separate mockups generated under the recorded image consent, presented through the existing card
and explicitly approved; never label mockups as screenshots. Outside that flow, honor the requested count and
approval method. Mockup consent is not consent for production assets.
## Shared art and audio production

### Asset reuse and targeted production
Reuse suitable supplied, template and already available assets within their recorded permissions and the user's
source restrictions; template reuse needs no extra approval. Replace only assets that conflict with the requested
theme, lack necessary states or look visibly wrong. A new game or reskin does not require replacing every image,
animation, icon, track or effect unless the user asks for original art or a full replacement. Retain unused
reference files and supplied license notices, describe reused assets honestly, and update visible titles and themed
copy. Rename internal IDs only when needed, together with their consumers, saves and tests.

### Coherent scene and title art
Fulfill the requested visual scope with readable actors, hazards, UI and a coherent scene. Simple intentional
visuals are acceptable within the recorded source choice. Title and loading screens may reuse permitted game art
with live text; no separate key art is needed. A download is not integration: inspect the affected scene.

### 3D texture budgets
Budget the project's stored textures, including bytes embedded in GLB/glTF, not catalog masters or import limits.
Longest edge: 256–512 for small or distant props, 1024 by default, 2048 for close main actors or shared atlases,
4096 only for a justified visible difference. Never upscale, and keep UVs, channel packing and material bindings
intact. Remove replaced embedded bytes, keep ancestry and sync the changed files. If suitable tools are missing,
report it rather than replacing working assets. Claim only measured savings.

### Continuous animation and alignment
Use the approved animation method. AI continuous motion goes from approved static references to a guided
fixed-camera, in-place video to fixed-FPS extracted loops; independent poses need an approved stepped style. Keep a
shared canvas, scale, pivot and contact anchor across states and facings instead of per-state placement patches, and
keep raw masters outside the game. Check representative movement, reversal and ground contact with the native
renderer.

### Mandatory background removal for composited assets
Composited sprites, icons, portraits, cursors and loader art need clean real alpha that survives resize, import and
export; check changed edges on contrasting backgrounds at display scale. Opaque plates and terrain are exempt. Keep
words, numbers and HUD labels live, and never slice concept collages into runtime assets. Generate cursors on a
hot-pink or neon-green background and remove it before use.

### Seamless parallax backgrounds
Repeating layers must tile left and right without mirroring; check the joins between adjacent copies at the intended
scale after any crop, import or scale change. Side-scrollers keep a low scenic foreground above world actors and
below the HUD without hiding combat.

### Audio production as needed
BGM is optional unless requested or essential to the brief. Reuse a fitting permitted template, supplied or catalog
track when the source restrictions allow; silence with safe empty routes is valid, and a new Max game is not a
reason to generate custom BGM. Honor explicit silence, supplied-only, AI-only and custom-music requests, and add only
useful event SFX. Generate audio only for an explicit request or a concrete
unmet need within recorded permissions: one usable result per needed track or cue, retried only for an actionable
correction. If requested custom music cannot be produced, report the unmet requirement. Audition changed audio and
ship compressed runtime audio, not raw WAV masters.

### Audio integration
Reuse the existing Music/SFX routing, gesture unlock and bounded voices, and keep empty routes safe across pause,
retry and scenes. New games that use audio keep the absolute base gains BGM 3× (+9.5424 dB) and SFX/UI 2×
(+6.0206 dB) over the inherited originals: place MusicBase/SfxBase before senders so each route crosses once,
replace old targets instead of stacking boosts, and keep the ≤0 dB guards, saved settings and explicit mixes.
Silent games need no gain plumbing, and existing delivered mixes stay unchanged. Spatial audio keeps real source
positions; music and global HUD sounds are separate. When music is used, keep the shared browser BGM adapter and
its native fallback.

### Asset generation mode gate
Recorded permissions decide what may be generated, regardless of mode or available tools. Hybrid, AI or explicit
permission covers its scoped generated visuals and SFX; mockup consent does not. For authorized images choose the
latest GPT Image model offered by the live schema unless the user named one. Tools record generation metadata
automatically; keep tool, provider, model and internal path details out of user-facing copy.

### Asset-production choice wording
Fast prototype follows its bounded workflow. New managed games call `webdev.init_project` once direction is clear,
with the complete brief; the canonical card settles unresolved choices, not parallel chat questions or a separate
Blueprint. Session-agent catalog search, access, downloads and delegation wait for successful initialization plus a
settled Blueprint, required plan and requested concept approval; in-flight or failed init is not success. Only
initialization's bounded metadata assessment may precede the card, never production downloads, generation or
integration. Standalone search or retrieval needs no project but does not justify speculative new-build sourcing.
Use the conversation language and call the catalog 游戏素材库 in Chinese. Recommend Hybrid mode for 2D, 3D and
unknown games. Card options for 2D/unknown: Manus game assets catalog, Hybrid mode, AI generation; Hybrid means
catalog plus AI art/audio, not scratch visuals. Known 3D: Game asset library and procedural generation, Hybrid mode,
AI generation. Only initialization's evidence-backed insufficient core-visual fit changes the first 3D label to
Procedural generation (Faster, lightweight, minimal token consumption); Unknown/sufficient fit or missing decoration
does not. Preserve historical accepted permissions; never infer them from option names or recommendations.
Only missing card support or a structured `planning_unavailable` receipt moves unresolved setup to one native
single-choice question; canonical state wins. For 2D/unknown: Manus game assets catalog, Hybrid (Recommended), AI
generated. Known 3D: Curated asset catalog and procedural (lowest token cost; catalog first, permitted gaps),
Hybrid (Recommended), AI generated (highest token cost). Keep these labels and this order, and record the answers.
No-questions sessions use
the recommended option within existing permission, which is not new consent. Additions to an existing game ask only
an unresolved production choice; delegation inherits constraints.
Accepted `choices.visualAssetSource: procedural` needs no repeated visual search/gap proof; audio follows its own
source restrictions and optional-production workflow. Catalog and Hybrid sourcing, including required-gap handling,
follows the game-asset-catalog Skill. Procedural permission never implies music composition.
## Shared Web runtime and delivery contract

### Browser-safe lifecycle
Bound and reuse voices, projectiles, particles, timers and subscriptions across pause, retry and scenes; change
pause or stream state on transitions, not every frame. Browser BGM uses the independent Web Audio renderer in
`scripts/manus/browser_bgm_player.gd`, never frame- or timer-fed PCM or finished-callback loops. It decodes once into
a bounded LRU AudioBuffer cache: call `prepare()` during loading or a transition before gameplay, then `play()`
reuses the buffer. Imported duplicates share an explicit original-path `buffer_key`, and changed PCM needs a new key.
Decode imported resources from the PCK, keep SFX in Godot and keep `thread_support=false`.
Route track, loop, position, pitch, mute, pause, duck, crossfade and Music/Master controls through the adapter.
External BGM does not inherit buses: mirror linear gain, limiter makeup and AudioEffectAmplify only. Keep native
Godot and the guarded Web fallback (`PLAYBACK_TYPE_STREAM` for long BGM) without overlapping backends; pending
autoplay waits for valid input, and stale starts are guarded. Stop voices and release removed cues with
`release_cached_stream()`, evict only unreferenced tracks, keep OS/bfcache suspend and restore, and release the context
on real teardown. Native tests cannot prove browser continuity through
main-thread stalls, so report that as pending user acceptance.

### Fast, recoverable startup
Keep the title and controls interactive with only the required fonts, UI, settings and small art. Defer scenes,
generation, media and decoding until needed, in bounded per-frame work; instantiate scenes on the main thread. Start
blocks duplicate transitions and reports recoverable content errors. Lazy PCK content reduces work, not transfer
bytes. Loading progress uses real bytes or phases and an indeterminate state for unknown totals; slow or stalled
notices are nonfatal, offer Retry, and clear on late success. When changing this mechanism, check cold load,
repeated Start, stall, unknown total, late success and Retry.

### Animated backgrounds without startup blocking
Show a small static placeholder immediately and keep it as the fallback. Load animations asynchronously after the
title is interactive, never as a Start or preload dependency, and swap on an actual ready frame while guarding exited
scenes and stale completions.

### Large explorable maps: presentation culling and live state
Offscreen simulation, pathfinding, orders, combat, economy, timers, replication, saves and the minimap stay live.
Cull only cosmetics against the current camera bounds, with sprite margins and separate fog, and never remove
gameplay actors, projectiles or collision by distance. Re-entering a region shows current state without replaying
missed effects. Optimize measured bottlenecks with existing spatial or dirty-region mechanisms, and compare crowded,
zoomed and revisited views against a baseline; empty-map FPS proves nothing.

### Destructible props
Destroyed rubble and fragments render below actors in effective world z while keeping footprint, collision release
and reward position; reset restores the intact state.

### Language scope and bundled fonts
Use the requested game language, defaulting to the conversation language. New games need no extra language or
EN/CN toggle unless requested; keep working localization on existing projects, and every exposed locale must be
complete. Keep player-facing words live instead of baked into art. Do not rebuild or re-audit the unchanged bundled
fonts; check changed text bindings, layouts and supported player names only. Keep name validation and save behavior,
and do not claim unsupported character coverage.

### Default typography
Default to the template's bundled theme: its display faces for titles/headings, its body face
(`assets/template/fonts/ui_{regular,medium,bold}.tres`) for UI text, then Noto Sans SC (6,547-codepoint repertoire)
for Chinese; Web loaders embed a small Noto Sans SC subset. Noto Sans SC is variable and its default instance is Thin,
so bind a weight through the template's font resources, not the raw file. Keep each bundled font's license
(`<Family>-OFL.txt`) beside it when copying, renaming or adding fonts; the Web export lists them on its Open Source
Licenses page. Missing template fonts restore from `assets.lock.json`; do not substitute system fonts. Existing
ManusCC0 projects keep their fonts unless the user asks for new typography. User-uploaded fonts are unrestricted: no
licensing, family, glyph-coverage, font-file, font-resource or font-pack size gates, and no rights review,
redistribution proof or notices. Theme or mood alone does not imply replacing the default fonts. This supersedes font
restrictions in frozen READMEs and local checks, including older ManusCC0 defaults: remove those policy gates when
integrating uploads, and keep only technical file-integrity and path checks.

### Viewport and background coverage
For fixed-coordinate Godot layouts set `[display]` `window/stretch/mode="canvas_items"`,
`window/stretch/aspect="keep"` and the logical viewport size; keep working adaptive layouts. Input targets the active
surface, not letterbox margins. Check affected desktop resize, aspect and DPR. Isometric zoom uses the ordinary
wheel or trackpad without Ctrl/Meta, with pointer-anchored picking; the HUD keeps a fixed scale. Mobile, touch and
portrait work follows the workflow's user-request rule even when template guides list those cases.

### Development Tweak when needed
The Addon generates the floating frosted-glass Tweak popover from the game's descriptors; never create an in-game
panel, launcher or F10 shortcut. Adapt the existing catalog to the requested game, extend it for meaningful tuning
and remove controls with no real consumer (at most 128). Keep one parameter manager with stable IDs, typed defaults,
bounds/options, localized labels, honest apply timing and existing run eligibility. Edits/reset affect only the
Addon draft. Apply validates and commits the whole patch without disk writes or preview reload; unchanged values
emit nothing. Gameplay boundaries consume pending values but never send catalogs. Do not add numeric revisions.
Save with Manus sends selected values to the task for source edits and the normal build/checkpoint flow; it does
not publish. Keep the adapter in `scripts/manus/preview/`, which release excludes with its autoload entry. Normal
player Settings and gameplay consumers remain. Existing genre rules below identify the actual parameter owners.

### Export constraints
Include runtime JSON/CSV/TXT through include_filter or Godot resources. Keep Web thread_support=false, resource paths discoverable, and the template-specific size budget. Use the Session port and the Addon preview/export workflow; do not hardcode the old Sandbox port or overwrite generated site/dist. Change identity through project.godot and the editable game loading shell, not generated HTML.

## Reference identity and purpose
`game-generic` is the Godot 4.7.2 fallback scaffold for Manus GameDev. Its reference game is **Generic Game Template**, a two-stage collection/chase game with a minimalist graphite, porcelain, and brushed-metal presentation. The title action is **START GAME**. Collect every energy node and power-up while avoiding sentinels; complete both circuits to win.

Select it only without a matching specialized genre; follow the [game-generic exception](#preserve-the-selected-template) for non-maze gameplay/UI.

The template intentionally contains **no default audio media**. Its silent baseline is an explicit template-owner choice; future adaptations follow the shared audio requirements and their user's choices.

## Source architecture
For an explicitly requested 3D game, initialization selects `scenes/manus_world_3d.tscn` with `scripts/manus/world_3d.gd`: this single owner supplies the Node3D world, camera and movement. Read those actual paths first. The layout below describes the original 2D reference, whose maze owners are not the active 3D scene. The 3D overlay is a starting scaffold; replace its primitive world and scaffold checks with the requested game and meaningful outcomes.
```text
game-generic/
├── project.godot                  # identity, input, autoloads, font, viewport
├── template.json                 # stable game-generic catalog identity
├── assets.lock.json              # Runtime v2 permanent CDN mappings
├── assets/template/
│   ├── environment/              # studio backdrop and sparse foreground
│   ├── characters/               # porcelain runner and metal sentinel
│   ├── powerups/                 # energy, overdrive, shield, slow field, magnet
│   ├── ui/                       # text-free title and pause glass artwork
│   ├── fonts/                    # Template display/body fonts, Noto Sans SC + OFL licenses
│   └── provenance/               # generation prompts and optional audio contract
├── autoload/
│   ├── audio_director.gd         # optional cues, buses, streaming, bounded voices
│   ├── i18n.gd                   # catalogs and fallback/interpolation
│   ├── save_store.gd             # local scores, player/locale/tutorial state
│   └── tuning_store.gd           # authoritative values and apply boundaries
├── scripts/
│   ├── main.gd                   # title, session, HUD, menus, tutorial routing
│   ├── manus/preview/            # Addon-only tuning transport and adapter
│   ├── game/{stage_catalog,maze_world}.gd
│   ├── entities/{runner,sentinel}.gd
│   ├── ui/{screen_factory,tutorial_callout}.gd
│   ├── effects/effects_director.gd
│   └── score/run_score_service.gd
├── config/tuning.json            # typed six-category tuning catalog
├── localization/{en,zh-CN}.json
├── docs/minimalist-redesign.md   # concept, implementation plan, evidence
├── test/test_suite.gd
└── tools/                       # finite verification adapters, native capture, bounded font installation
```

`MazeWorld` owns simulation, `RunScoreService` owns score/finalization, and `TuningStore` owns configuration and run integrity. UI, art, shaders, particles and audio present that state. Save keys, stage IDs and tuning IDs remain compatible with earlier template runs; creative runtime IDs have been renamed to neutral terms.

## Game Addon tweaks
Reuse `config/tuning.json`, `TuningStore` and `scripts/manus/preview/tuning_adapter.gd`. The Addon generates its floating frosted-glass popover from game descriptors without resizing the preview; game code supplies parameters, not panel styling. Adapt or extend the examples for the requested game, with real consumers, stable IDs, localized labels/categories/descriptions, defaults, bounds/steps, integrity and honest LIVE/NEXT_ACTION/NEXT_STAGE/NEXT_RUN timing. Generic currently supports up to 128 number/boolean controls; other types need game-side support.

Keep one store and existing run-eligibility rules. Edits and resets change only the panel draft; unchanged or invalid drafts cannot Apply. Apply validates/commits the whole patch without persistence or reload; deferred values activate at their declared gameplay boundaries. Unchanged values emit nothing, and gameplay events never push catalogs. Do not add numeric tuning revisions.

After Apply, Save with Manus reads a snapshot and sends it to the task for source edits and normal build/checkpoint, never auto-publish. Release excludes the debug bridge and overrides while retaining source defaults and gameplay consumers.

These rules override frozen README tuning instructions: do not recreate a native panel, launcher, F10 shortcut or native Tweak capture. Preserve existing protocol/runtime guards; ordinary game generation needs no Addon transport implementation reading.

## Run and verify
```bash
npm run check                   # finite import, boot and game-owned outcome hooks
npm run build                   # current standalone export through the shared runtime
npm run check -- --pack          # verify that current export and applicable outcome hooks
```
Use the runtime directory returned by init/attach and the installed Game workflow. Keep meaningful game-specific hooks in optional `game-verification.json`; an absent hook file is normal before one is needed. Fresh compatibility aliases delegate to this same finite verifier. Older READMEs and `tools/verify.sh` may hardcode the maze scene, obsolete resource-audit assumptions or a different `dist/index.pck`; adapt relevant outcome hooks instead of repairing that separate pipeline. Asset sync/build own dependency, hash and current-export checks. The Web preset uses `thread_support=false`; developer tools and fixtures stay outside the playable export.

The original 2D reference's native capture uses the actual viewport and renderer; adapt its scene/state selectors for another game and run without `--editor`:
```bash
GRANDTOUR_CAPTURE_PATH=/absolute/path/post-office.png godot --path . --script tools/capture_native.gd
GRANDTOUR_CAPTURE_PATH=/absolute/path/angkor.png GRANDTOUR_CAPTURE_STOP=angkor_wat GRANDTOUR_CAPTURE_VIEW=2 godot --path . --script tools/capture_native.gd
GRANDTOUR_CAPTURE_PATH=/absolute/path/pause.png GRANDTOUR_CAPTURE_PAUSE=1 godot --path . --script tools/capture_native.gd
```
Use a real renderer; headless Dummy output is not visual evidence. Capture stop IDs come from the travel catalog; view indices start at zero. The old GENERIC2D_CAPTURE_PATH and GENERIC2D_CAPTURE_PAUSE names remain compatible.

## Controls and playable loop

Click reachable ground to walk; click a labelled target to approach and interact. Escape closes a dialogue or toggles pause. The route book selects destinations; Next Stop follows the active destination route. Observation-only stops use explicit reading, impression and record actions. Post office postcards, palace souvenirs and individual travel records save separately.

## Retained template utilities: stage and score contracts
`StageCatalog.STAGES` stores 21×17 layouts, palette, spawn positions and speed multipliers. Validation checks legal symbols, rectangular rows, exactly one player spawn, enemies, collectibles and connected walkable cells. Add stages through catalog data rather than duplicating the controller.

| Symbol | Meaning | Score/event |
| --- | --- | --- |
| `#` | Connected solid wall | None |
| `.` | Energy node | `energy`: 10 |
| `o` | Overdrive; permits disabling sentinels | `overdrive`: 50 |
| `s` | Shield; collision protection | `powerup`: 75 |
| `t` | Slow field; enemy slowdown | `powerup`: 75 |
| `m` | Magnet; nearby connected-node collection | `powerup`: 75 |
| `P` | Player spawn | None |
| `E` | Sentinel spawn | `sentinel_disable`: 200 when overdriven |

Clearing a stage awards `stage_clear`: 500. `RunScoreService.authored_collectible_maximum()` excludes repeatable sentinel disables. Score is bounded to 999,999,999; `finalize()` produces an immutable once-only result containing score, stage, outcome, duration, tutorial status and integrity marker.

## Retained template presentation reference
`ScreenFactory` owns graphite panels, hairlines, cool blue focus states, neutral secondary buttons and the light primary action. Real Godot text renders every label. The HUD uses separate status and wrapping effect rows; power-up timers remain visible in portrait. World scaling fits below the HUD and leaves touch-control space. Actor sprites remain centered on their grid positions without vertical bobbing.

The reference uses eleven separately generated original raster assets. Prompt/source/runtime mappings are recorded in `assets/template/provenance/IMAGEGEN.md`. Original generated outputs remain in generation history; shipped media is restored from permanent CDN mappings. No old picnic art or default sound assets are part of the current payload. Connected maze walls and path-facing borders remain code-native.

The effects director owns twelve recycled burst emitters and one ambient emitter. Reduced Motion disables ambient movement and uses restrained feedback. The default particle density is 0.4 and studio filter strength is 0.18. There is no continuous player trail.

## Optional audio engine
`AudioDirector.CUES` retains semantic IDs for logical title/gameplay music, confirm/cancel, action, impact, reward, pause, victory and defeat. All default paths are empty. Master/Music/SFX/UI buses, two music channels through the [shared browser BGM adapter/native fallback](#browser-safe-lifecycle), eight effect voices, two UI voices, crossfade, looping, pause ducking and mute/volume remain intact.
Apply [shared audio sourcing](#audio-production-as-needed): music routes remain empty for silent BGM or share one approved track; required SFX are independent.

```gdscript
# After importing project-owned audio:
AudioDirector.register_cue("score.reward", "res://assets/template/audio/reward.ogg")
# Only when BGM is implemented under the shared audio workflow:
AudioDirector.register_cue("music.title", "res://assets/template/audio/music.ogg")
AudioDirector.register_cue("music.gameplay", "res://assets/template/audio/music.ogg")
```
`register_stream()` accepts an existing AudioStream; `unregister_cue()` clears it. Empty/missing resources, wrong resource types, null streams and unknown IDs return `false` safely. A missing music route stops previous music. There are no synthetic fallback tones or automatic downloads. A real button/input gesture unlocks playback. Tests use an in-memory fixture, never a shipped placeholder file. See `assets/template/provenance/AUDIO.md`.

## Retained local standings utility
Local top-ten standings persist scores and configuration provenance. No dormant global-leaderboard adapter or hidden network UI ships. Add global integration only when explicitly requested.

## Localization and fonts
Uploads follow [shared typography](#default-typography); update project-local checks. Visible copy uses `I18n.t(key, replacements)`. By default `assets/template/fonts/ui_regular.tres` binds the template body face with `assets/template/fonts/NotoSansSC-VF.subset.woff2` fallback. Verify its full common-character repertoire:
```bash
python3 tools/install_cjk_font.py --check
```
Checks cover key parity, Chinese/player-name glyphs and the primary font. Default runtime/loader fonts are OFL; keep each `<Family>-OFL.txt` beside its font. `tools/build_cjk_font_subset.py` launches the default-font installer; fixed loader text uses a separately pinned subset.
