# 两条路线与 12 个景点

2026-10-15。按现有水彩绘本风格扩展《The Grand Tour》。保留独立宫、中央邮局及其任务，新增 10 个有独立背景与互动的外部探索场景。每站由 Archie 实际走到介绍牌、互动对象和旅行记录点，转场通过纸面路线册或下一站按钮执行。

## 路线与互动

| 路线 | 景点 | 可玩内容 |
| --- | --- | --- |
| 1 | 独立宫 | 原有建筑、庭院、大厅展览与参观纪念 |
| 1 | 红教堂 | 外观观察，选择双塔、红砖或入口的建筑笔记 |
| 1 | 中央邮局 | 原有摄影师、介绍牌、室内书写与投递明信片 |
| 1 | 阮文平书街 | 在书摊选择建筑、旅行或植物主题的读物 |
| 1 | 市政厅 | 在广场速写架选择构图重点 |
| 1 | 歌剧院 | 阅读虚构节目单，想象一段旅途序曲 |
| 1 | 阮惠步行街 | 记录树影、建筑或傍晚色彩 |
| 1 | 咖啡公寓 | 街边滴滤咖啡、阳台观察或休息笔记 |
| 2 | 滨城市场 | 在水果摊选择一种热带水果的颜色印象 |
| 2 | 胡志明市美术馆 | 在原创抽象画展架前写颜色笔记 |
| 2 | 粉红教堂 | 在水彩架前选择一组建筑配色 |
| 2 | 战争遗迹博物馆 | 阅读非图像化简介，写下和平寄语 |

新站需完成阅读与互动两项，再走到前方记录点确认，才显示完成标记；仅到达不算完成。选择会保留在该站手记中。路线册支持自由选站，路线二保留用户指定次序，并在粉红教堂前后标记乘车转场。路线说明也提示可将战争遗迹博物馆与独立宫一起参观，减少折返。

## 实现

- `scripts/game/tour_catalog.gd`：两条路线、12 个站点及 10 个新增活动的文案与选项。
- `scripts/game/tour_world.gd`：按最终图片校准的地面边界、物件碰撞和交互站位。边界供导航与物理共同使用。
- `scripts/game/tour_progress.gd`：10 站的阅读、选项和记录状态；恢复时丢弃未知站点和无效选择。
- `saigon_exploration.gd`：沿用原移动、互动与淡入淡出，接入新站与路线册。
- `exploration_ui.gd`：同一纸面字体与配色的路线册，显示进度、当前位置和已记录标记。
- `SaveStore.tour_progress`：独立字段，保留旧明信片和独立宫存档。旧存档缺少字段时默认为空。

10 幅新画使用内置 `image_gen.imagegen`，每站单独生成；未用 API/CLI 回退。源 PNG 在 `assets/game/scenes/tour-*.png`，JPEG 运行素材在 `assets/game/runtime/tour-*.jpg`，完整提示词和逐文件路径记录于 `tour-art-prompts.json`。`python3 tools/prepare_tour_art.py` 可重新生成 1600 × 900 的 JPEG。源画不随 Web 版本打包。

## 地标与内容参考

仅使用简短、稳定的建筑与文化特征，不加入未经核实的即时开放时间、价格、演出场次或修缮完成日期。场景是供游戏探索的绘本诠释，部分道路被表达为安全步行空间，不能作为实地交通图。教堂、市政厅和歌剧院均不以内部开放为玩法条件。美术馆展架的抽象画和剧院节目单为原创虚构内容，未复制真实馆藏或演出。

- [Vietnam Tourism · Ho Chi Minh City](https://vietnam.travel/places-to-go/southern-vietnam/ho-chi-minh-city/)：市中心地标群和滨城市场。
- [Vietnam Tourism · The perfect weekend in HCMC](https://vietnam.travel/node/470)：教堂、邮局、歌剧院、阮惠步行街与 42 号咖啡公寓。
- [Vietnam Tourism · 7 must-see attractions in HCMC](https://vietnam.travel/node/137)：阮惠步行街、市政厅与地标外观。
- [Vietnam Tourism · Vietnam's must-see museums](https://vietnam.travel/things-to-do/best-museums-vietnam)：胡志明市美术馆与战争遗迹博物馆的基本内容。
- [Ho Chi Minh City Tourism · Tan Dinh Church](https://visithcmc.net/en/news/kham-pha-nha-tho-tan-dinh-net-hong-doc-dao-dep-nhat-sai-gon)：新定教堂的粉红外观与钟塔。
- [Vietnam Airlines · Ho Chi Minh City Book Street](https://www.vietnamairlines.com/in/en/plan-book/travel/travel-guide/ho-chi-minh-city-book-street)：阮文平书街及其阅读空间。

字体继续使用已打包的 Figtree、Noto Sans SC 和越南语回退字体。`tour_suite.gd` 检查新增文案的字符覆盖，避免再出现越南语缺字问题。

## 验证记录

- 六套源项目测试通过：探索 75、明信片 70、地面碰撞 46、Archie 动画 12、独立宫 75、新路线 221 项检查。
- 真实 OpenGL 渲染走完新路线交互，保存 10 个新站的场景/手记和两张路线册截图于 `dist/tour-qa/`，已逐站检查。
- Web 导出包验证通过，确认 10 个运行背景存在、源画不打包、12 站可构建。
- 本地浏览器实际打开两条路线册并进入滨城市场，无控制台错误。
- 本地验证版本为 `two-routes-20261015`；线上版本由 GitHub Actions 使用提交号生成资源地址。
