# 西贡路线与 12 个景点

2026-10-22：新增「旅行画册」封面入口，将西贡、吴哥、大同及周边分为独立旅程，支持各自续游。大同篇共八站：古城墙、华严寺、善化寺、九龙壁、云冈石窟、恒山、悬空寺、应县木塔。应县木塔归属朔州应县；本篇按大同及周边组织。云冈与九龙壁的前方铺地支持漫步，其余六幅为观景视角。插画源自用户确认的悬空寺精修画风，逐站实景与生成记录见 `datong-art/production-v1.json`。

2026-10-20：中央邮局保留摄影师、介绍牌、室内书写与投递明信片的探索任务。其余 11 个西贡景点及 26 个吴哥景点都只保留一个「景点介绍」入口；不再提供三选一互动、记录确认、独立宫大厅任务或纪念收集。

路线顺序、全部目的地与背景、地面漫步和已有视角切换继续保留。介绍从左上角按钮直接打开。路线册支持自由选站，粉红教堂前后保留乘车转场提示。完成标记只显示邮局明信片是否寄出。

旧存档中的旅行记录和独立宫进度仍由存档层兼容保存，当前场景不再读取这些字段作为任务。

运行素材与创作记录见 `tour-art-prompts.json`。

## 地标与内容参考

仅使用简短、稳定的建筑与文化特征，不加入未经核实的即时开放时间、价格、演出场次或修缮完成日期。场景是供游戏探索的绘本诠释，部分道路被表达为安全步行空间，不能作为实地交通图。教堂、市政厅和歌剧院均不以内部开放为玩法条件。

- [Vietnam Tourism · Ho Chi Minh City](https://vietnam.travel/places-to-go/southern-vietnam/ho-chi-minh-city/)：市中心地标群和滨城市场。
- [Vietnam Tourism · The perfect weekend in HCMC](https://vietnam.travel/node/470)：教堂、邮局、歌剧院、阮惠步行街与 42 号咖啡公寓。
- [Vietnam Tourism · 7 must-see attractions in HCMC](https://vietnam.travel/node/137)：阮惠步行街、市政厅与地标外观。
- [Vietnam Tourism · Vietnam's must-see museums](https://vietnam.travel/things-to-do/best-museums-vietnam)：胡志明市美术馆与战争遗迹博物馆的基本内容。
- [Ho Chi Minh City Tourism · Tan Dinh Church](https://visithcmc.net/en/news/kham-pha-nha-tho-tan-dinh-net-hong-doc-dao-dep-nhat-sai-gon)：新定教堂的粉红外观与钟塔。
- [Vietnam Airlines · Ho Chi Minh City Book Street](https://www.vietnamairlines.com/in/en/plan-book/travel/travel-guide/ho-chi-minh-city-book-street)：阮文平书街及其阅读空间。

字体继续使用已打包的 Figtree、Noto Sans SC 和越南语回退字体。

## 历史验证记录（简化前）

- 六套源项目测试通过：探索 75、明信片 70、地面碰撞 46、Archie 动画 12、独立宫 75、新路线 221 项检查。
- 真实 OpenGL 渲染走完新路线交互，保存 10 个新站的场景/手记和两张路线册截图于 `dist/tour-qa/`，已逐站检查。
- Web 导出包验证通过，确认 10 个运行背景存在、源画不打包、12 站可构建。
- 本地浏览器实际打开两条路线册并进入滨城市场，无控制台错误。
- 本地验证版本为 `two-routes-20261015`；线上版本由 GitHub Actions 使用提交号生成资源地址。
