# 西贡路线与 12 个景点

## 土耳其 · 2026-10-23

新增独立旅行画册，按用户给定的四区清单保留全部 30 站及其顺序。每册独立保存续游位置；土耳其的「下一站」跨区连续前进，末站返回土耳其路线册。

- 伊斯坦布尔：博斯普鲁斯海峡 → 圣索菲亚大教堂 → 老皇宫 → 蓝色清真寺 → 君士坦丁堡竞技场遗址 → 锡尔凯吉火车站 → 纯真博物馆 → 独立大街 → 加拉太塔 → 如梅利堡垒。
- 卡帕多奇亚：安纳托利亚高原 → 格雷梅 → 内夫谢希尔 → 凯马克利 → 鸽子谷 → 乌奇萨尔 → 格雷梅露天博物馆 → 阿瓦诺斯 → 红谷。
- 伊兹密尔周边：塞尔丘克（Selçuk）→ 以弗所古城（Ephesus）→ 切什梅（Çeşme）→ 阿拉恰特（Alaçatı）→ 大电梯 → 市中心钟楼。
- 安塔利亚周边：安塔利亚机场 → 西代 / Side → 阿波罗神庙 → 阿斯潘多斯古剧场（Aspendos）→ 佩尔格古城（Perge）。

老皇宫按托普卡帕宫处理；市中心钟楼为伊兹密尔科纳克钟楼；阿波罗神庙为西代海边遗址。安纳托利亚高原是广域地理名称，本站以卡帕多奇亚高原地貌为窗口，与格雷梅城镇、内夫谢希尔城堡分别呈现。西代采用柱廊街道视角，与阿波罗神庙区分。

画风固定参考最初的中央邮局，采用用户认可的圣索菲亚修正版：细棕线建筑、克制的水彩色块、清楚的结构和细微纸纹。每幅始终使用原始邮局作为画风参考，避免插画之间逐代转绘造成漂移。实景照片用于地标结构，画面构图和光线属于绘本诠释。没有凭空补建古迹；场景不作为测绘地图、即时开放信息或实地交通指南。

君士坦丁堡竞技场遗址、纯真博物馆、独立大街、塞尔丘克、以弗所、阿拉恰特和西代共七站设置明确地面边界；台阶、围栏、立柱、桌椅、电车与轨道外的区域不纳入地面。海峡、俯瞰景观、岩堡、地下城和剧场等其余视角以观景为主。

实景资料来自 [GoTürkiye](https://goturkiye.com/istanbul/destinations)、[卡帕多奇亚遗产管理机构](https://kapadokyaalan.ktb.gov.tr/cappadokia/visit-points)、[土耳其文化门户](https://www.kulturportali.gov.tr/)、[纯真博物馆](https://www.masumiyetmuzesi.org/en)和[机场运营方 Fraport](https://www.fraport.com/en/business-areas/international-activities/antalya-airport.html)。锡尔凯吉站房使用 [METU 机构页面保存的历史照片](https://users.metu.edu.tr/tonuk/E40003/Sirkeci/)，色彩为绘本诠释，景点介绍中保留这一说明。逐站原图地址、校验值、生成提示与最终映射见 `turkey-art/production-v1.json`。

2026-10-22：新增「旅行画册」封面入口，将西贡、吴哥、大同及周边分为独立旅程，支持各自续游。大同篇按用户要求移除恒山，共七站：古城墙、华严寺、善化寺、九龙壁、云冈石窟、悬空寺、应县木塔。应县木塔归属朔州应县；本篇按大同及周边组织。云冈与九龙壁的前方铺地支持漫步，其余五幅为观景视角。插画源自用户确认的悬空寺精修画风，逐站实景与生成记录见 `datong-art/production-v1.json`。

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
