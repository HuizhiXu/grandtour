# 第二站 · 独立宫

2026-10-15。新增独立宫庭院与参观大厅，接续中央邮局。沿用 Archie、点击寻路、纸本界面及原有中文字体。邮局任务和独立宫参观分别保存；旧存档缺少 `palace_visit` 时默认为未参观。

## 美术与参考

两幅新画使用内置 `image_gen.imagegen` 生成，未使用 API/CLI 回退，未下载或复制第三方摄影作品。庭院根据地标特征绘制；大厅为绘本化参观空间，并非精确的历史室内复原。游戏中的参观纪念属于虚构玩法。

- [独立宫官网 · 建筑](https://dinhdoclap.gov.vn/en/independence-palace-architecture/)：建筑设计、年代与建筑语言。
- [独立宫官网 · 历史](https://dinhdoclap.gov.vn/en/history-of-the-independent-palace/)：历史背景。游戏只保留简短事实说明。
- `assets/game/scenes/independence-palace.png` → `assets/game/runtime/independence-palace.jpg`
- `assets/game/scenes/independence-palace-hall.png` → `assets/game/runtime/independence-palace-hall.jpg`

原始 PNG 保存在项目中，发行版本只引用压缩 JPEG。使用 `python3 tools/prepare_palace_art.py` 可重新生成运行素材：1600 × 900，JPEG quality 91、渐进编码。场景以 0.8 倍显示在 1280 × 720 世界中。

## 庭院生成提示词

```text
Use case: stylized-concept. Create a production game background for The Grand Tour, a warm hand-inked watercolor travel picture book 2D point and click game. ONE full-bleed 16:9 landscape image, ideally 1600x900. Subject: recognizable Independence Palace (Dinh Doc Lap/Reunification Palace), Ho Chi Minh City, Vietnam. Accurate broad low cream modernist facade, three horizontal stories with dense vertical concrete bamboo-like sun screens, flat roof and central rooftop pavilion, small Vietnamese flag. Elevated three-quarter view with slight isometric perspective. Building fills upper half, entrance at center x=800 y=430 (in 1600x900 coordinates). Continuous clear pale stone forecourt from y=500 through bottom edge, central entrance accessible by broad paved approach. A broad oval green lawn with a low circular fountain is centered at x=800 y=615, bounded within x=580..1020,y=530..700; clear paving on BOTH sides and below it, route from bottom center around either side of lawn to entrance. Tall tropical trees frame far left and right. Small blank visitor information plaque at x=1240 y=540; small blank stone viewing plaque near x=420 y=600. No people or characters. No UI, no lettering, no border. Muted leafy greens, cream limestone, warm natural daylight, fine brown ink lines, dense architectural detail, restrained watercolor paper texture matching a cozy illustrated travel diorama. Avoid colonial arches or red tiled roof. This is a playable background with legible empty walkable paved areas.
```

## 大厅生成提示词

```text
Use case: stylized-concept. Production 16:9 landscape game background ideally 1600x900, for The Grand Tour 2D point and click travel game. Warm watercolor and fine brown architectural ink on ivory paper, muted cream and moss green, detailed cozy travel sketchbook diorama. Interior visitor lobby of Independence Palace (Dinh Doc Lap), Ho Chi Minh City: mid-century Vietnamese modernism, flat coffered ceiling, cream square structural columns framing sides, polished cream stone floor with subtle geometric grid, central long perspective, wood accents, a glimpse of a formal historic reception room behind a low rope barrier across rear at y=400. Open spacious central visitor floor across x=260..1340, y=430..900, with NO furniture in the center. All furniture in side corners, low information exhibit desk on right wall x=1270 y=470, architectural display panel with illegible small marks at rear center x=800 y=340. A wide open exit threshold centered in bottom edge x=800. View from elevated slight three-quarter angle looking into hall. Match a hand-painted watercolor travel game exterior, crisp ink details, natural daylight, elegant restrained greens and warm timber. No characters, no UI, no readable text, no arched colonial postal hall, no fantasy ornaments. This is an interpretive illustration of the visitor hall, not an exact historical reconstruction. Keep walkable foreground empty and clearly legible.
```

## 交互与地面

`saigon_exploration.gd` 管理 `palace_garden`、`palace_hall` 与邮局的往返。可走边界共享给导航与物理碰撞，椭圆草坪使用 32 边碰撞多边形；人物需要实际走到站位才能阅读或切场。所有站位按照最终背景校准，而非按生成提示词中的预期坐标。

`palace_visit.gd` 管理建筑、观景、展览与纪念进度。前三处允许自由参观，纪念必须在前三处完成后走到大厅参观台并确认领取。HUD 按当前地点显示对应任务，远程打开不会领取纪念。
