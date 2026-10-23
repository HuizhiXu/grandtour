extends RefCounted
## User-specified 30-stop itinerary. Sources: docs/turkey-art/production-v1.json.

const ROUTES: Array[Dictionary] = [
	{
		"journey": "turkey",
		"title": "伊斯坦布尔市内游览",
		"tab": "伊斯坦布尔",
		"subtitle": "博斯普鲁斯海峡 → 圣索菲亚大教堂 → 老皇宫 → 蓝色清真寺 → 君士坦丁堡竞技场遗址 → 锡尔凯吉火车站 → 纯真博物馆 → 独立大街 → 加拉太塔 → 如梅利堡垒",
		"note": "从博斯普鲁斯海峡出发，翻阅历史半岛、铁路与文学记忆，再到独立大街、加拉太塔和如梅利堡垒。老皇宫在本册指托普卡帕宫。共十站，可滚动选看。",
		"stops": [
			"turkey_bosphorus",
			"turkey_hagia_sophia",
			"turkey_topkapi",
			"turkey_blue_mosque",
			"turkey_hippodrome",
			"turkey_sirkeci",
			"turkey_innocence",
			"turkey_istiklal",
			"turkey_galata",
			"turkey_rumeli"
		]
	},
	{
		"journey": "turkey",
		"title": "卡帕多奇亚地区",
		"tab": "卡帕多奇亚",
		"subtitle": "安纳托利亚高原 → 格雷梅 → 内夫谢希尔 → 凯马克利 → 鸽子谷 → 乌奇萨尔 → 格雷梅露天博物馆 → 阿瓦诺斯 → 红谷",
		"note": "按清单顺序，从安纳托利亚高原翻到格雷梅、内夫谢希尔与地下城，再看山谷、岩堡、露天博物馆和陶艺小镇。安纳托利亚高原是一片广阔地理区域，本站以卡帕多奇亚一带的高原地貌作为窗口。",
		"stops": [
			"turkey_anatolian_plateau",
			"turkey_goreme",
			"turkey_nevsehir",
			"turkey_kaymakli",
			"turkey_pigeon_valley",
			"turkey_uchisar",
			"turkey_goreme_museum",
			"turkey_avanos",
			"turkey_red_valley"
		]
	},
	{
		"journey": "turkey",
		"title": "伊兹密尔周边",
		"tab": "伊兹密尔",
		"subtitle": "塞尔丘克（Selçuk） → 以弗所古城（Ephesus） → 切什梅（Çeşme） → 阿拉恰特（Alaçatı） → 大电梯 → 市中心钟楼",
		"note": "先看塞尔丘克与以弗所，再翻向切什梅、阿拉恰特，最后回到伊兹密尔市区的大电梯与钟楼。市中心钟楼在本册指科纳克广场的伊兹密尔钟楼。",
		"stops": [
			"turkey_selcuk",
			"turkey_ephesus",
			"turkey_cesme",
			"turkey_alacati",
			"turkey_asansor",
			"turkey_clock_tower"
		]
	},
	{
		"journey": "turkey",
		"title": "安塔利亚周边",
		"tab": "安塔利亚",
		"subtitle": "安塔利亚机场 → 西代 / Side → 阿波罗神庙 → 阿斯潘多斯古剧场（Aspendos） → 佩尔格古城（Perge）",
		"note": "从安塔利亚机场翻开地中海沿岸篇章，依次前往西代、阿波罗神庙、阿斯潘多斯古剧场与佩尔格古城。阿波罗神庙是西代海边的遗址，与西代城镇分别设站。",
		"stops": [
			"turkey_antalya_airport",
			"turkey_side",
			"turkey_apollo",
			"turkey_aspendos",
			"turkey_perge"
		]
	}
]

const STOPS: Dictionary = {
	"turkey_bosphorus": {
		"title": "博斯普鲁斯海峡",
		"scene": "turkey_bosphorus",
		"region": "伊斯坦布尔",
		"area": "伊斯坦布尔 · 博斯普鲁斯海峡",
		"observation_only": true,
		"info": "博斯普鲁斯海峡连接黑海与马尔马拉海，两岸分别属于欧洲和亚洲。渡轮、沿岸宅邸与跨海峡大桥，把伊斯坦布尔的城市生活连在一起。"
	},
	"turkey_hagia_sophia": {
		"title": "圣索菲亚大教堂",
		"scene": "turkey_hagia_sophia",
		"region": "伊斯坦布尔",
		"area": "伊斯坦布尔 · 历史半岛",
		"observation_only": true,
		"info": "圣索菲亚始建为拜占庭教堂，巨大的穹顶与层层支撑结构见证了伊斯坦布尔的历史变迁。今天它是一座清真寺；本册保留常用中文名称，从外观认识这座建筑。"
	},
	"turkey_topkapi": {
		"title": "老皇宫",
		"scene": "turkey_topkapi",
		"region": "伊斯坦布尔",
		"area": "伊斯坦布尔 · 历史半岛",
		"observation_only": true,
		"info": "老皇宫在这里指托普卡帕宫（Topkapı Palace），曾是奥斯曼帝国的宫廷与行政中心。庭院、门楼和宫殿沿半岛展开，与博斯普鲁斯海峡相望。"
	},
	"turkey_blue_mosque": {
		"title": "蓝色清真寺",
		"scene": "turkey_blue_mosque",
		"region": "伊斯坦布尔",
		"area": "伊斯坦布尔 · 历史半岛",
		"observation_only": true,
		"info": "蓝色清真寺又名苏丹艾哈迈德清真寺，以层叠穹顶和六座宣礼塔形成醒目的轮廓。它与圣索菲亚隔广场相望，名称源于内部著名的蓝色瓷砖装饰。"
	},
	"turkey_hippodrome": {
		"title": "君士坦丁堡竞技场遗址",
		"scene": "turkey_hippodrome",
		"region": "伊斯坦布尔",
		"area": "伊斯坦布尔 · 历史半岛",
		"observation_only": false,
		"info": "今天的苏丹艾哈迈德广场保留着古代君士坦丁堡竞技场的历史痕迹。方尖碑与蛇柱等遗存提示着这里曾经的公共生活；本册呈现现存广场，不复原已消失的看台。"
	},
	"turkey_sirkeci": {
		"title": "锡尔凯吉火车站",
		"scene": "turkey_sirkeci",
		"region": "伊斯坦布尔",
		"area": "伊斯坦布尔 · 锡尔凯吉",
		"observation_only": true,
		"info": "锡尔凯吉火车站位于伊斯坦布尔欧洲一侧，承载着东方快车时代的铁路记忆。老站房的拱窗与立面装饰，让抵达与远行成为这座城市故事的一部分。本幅以机构保存的历史站房照片为线索，呈现铁路记忆中的立面；色彩为绘本诠释。"
	},
	"turkey_innocence": {
		"title": "纯真博物馆",
		"scene": "turkey_innocence",
		"region": "伊斯坦布尔",
		"area": "伊斯坦布尔 · 楚库尔朱马",
		"observation_only": false,
		"info": "纯真博物馆由作家奥尔罕·帕慕克创建，与他的同名小说相互呼应。日常物件、橱窗与记忆在这里交织，把文学故事放回伊斯坦布尔的街巷生活。"
	},
	"turkey_istiklal": {
		"title": "独立大街",
		"scene": "turkey_istiklal",
		"region": "伊斯坦布尔",
		"area": "伊斯坦布尔 · 贝伊奥卢",
		"observation_only": false,
		"info": "独立大街位于贝伊奥卢，历史楼房、商店与文化空间沿街展开。红色怀旧电车穿行其间，与来往行人一起构成伊斯坦布尔熟悉的街景。"
	},
	"turkey_galata": {
		"title": "加拉太塔",
		"scene": "turkey_galata",
		"region": "伊斯坦布尔",
		"area": "伊斯坦布尔 · 加拉太",
		"observation_only": true,
		"info": "加拉太塔以圆筒石砌塔身和锥形屋顶，从周围街区的屋顶间升起。这座历史塔楼是认识金角湾与伊斯坦布尔城市轮廓的一处地标。"
	},
	"turkey_rumeli": {
		"title": "如梅利堡垒",
		"scene": "turkey_rumeli",
		"region": "伊斯坦布尔",
		"area": "伊斯坦布尔 · 博斯普鲁斯西岸",
		"observation_only": true,
		"info": "如梅利堡垒（Rumeli Fortress）建在博斯普鲁斯海峡欧洲一侧的山坡上。厚重圆塔和连接山势的城墙，体现了这处海峡要地的防御格局。"
	},
	"turkey_anatolian_plateau": {
		"title": "安纳托利亚高原",
		"scene": "turkey_anatolian_plateau",
		"region": "卡帕多奇亚",
		"area": "卡帕多奇亚 · 安纳托利亚高原",
		"observation_only": true,
		"info": "安纳托利亚高原覆盖土耳其中部的广阔地区，卡帕多奇亚是其中一片独特的火山地貌区域。本册从这里的高原景观认识凝灰岩台地、沟谷与风化岩柱，随后走向具体城镇。"
	},
	"turkey_goreme": {
		"title": "格雷梅",
		"scene": "turkey_goreme",
		"region": "卡帕多奇亚",
		"area": "卡帕多奇亚 · 格雷梅",
		"observation_only": true,
		"info": "格雷梅坐落在卡帕多奇亚的凝灰岩地貌之间，石屋与岩柱共同构成小镇的轮廓。这里既是一座有人生活的城镇，也是一扇认识周围山谷与岩窟文化的窗口。"
	},
	"turkey_nevsehir": {
		"title": "内夫谢希尔",
		"scene": "turkey_nevsehir",
		"region": "卡帕多奇亚",
		"area": "卡帕多奇亚 · 内夫谢希尔",
		"observation_only": true,
		"info": "内夫谢希尔是卡帕多奇亚地区的重要城市，山丘上的城堡与周围聚落记录着不同年代的生活。本站以城市与城堡外观为线索，与格雷梅的山谷小镇景观分别呈现。"
	},
	"turkey_kaymakli": {
		"title": "凯马克利",
		"scene": "turkey_kaymakli",
		"region": "卡帕多奇亚",
		"area": "卡帕多奇亚 · 凯马克利",
		"observation_only": true,
		"info": "凯马克利以地下城闻名，岩层中开凿的通道与房间连接着储藏、居住和公共空间。顺着有限的光线观察岩壁，可以体会人们利用地质条件组织生活与庇护空间的方式。"
	},
	"turkey_pigeon_valley": {
		"title": "鸽子谷",
		"scene": "turkey_pigeon_valley",
		"region": "卡帕多奇亚",
		"area": "卡帕多奇亚 · 鸽子谷",
		"observation_only": true,
		"info": "鸽子谷位于格雷梅与乌奇萨尔之间，谷壁上可见人工开凿的鸽舍。浅色凝灰岩、绿地与岩壁孔洞，让自然侵蚀和当地农业生活的痕迹同时进入视野。"
	},
	"turkey_uchisar": {
		"title": "乌奇萨尔",
		"scene": "turkey_uchisar",
		"region": "卡帕多奇亚",
		"area": "卡帕多奇亚 · 乌奇萨尔",
		"observation_only": true,
		"info": "乌奇萨尔的巨大岩堡从周围聚落间拔起，岩体中保留着开凿的洞室与孔洞。它与山坡上的石屋相连，是卡帕多奇亚容易辨认的地标之一。"
	},
	"turkey_goreme_museum": {
		"title": "格雷梅露天博物馆",
		"scene": "turkey_goreme_museum",
		"region": "卡帕多奇亚",
		"area": "卡帕多奇亚 · 格雷梅露天博物馆",
		"observation_only": true,
		"info": "格雷梅露天博物馆保存了开凿在岩石中的教堂与修道空间。岩壁、入口和内部壁画共同讲述拜占庭时期的宗教生活；本幅从窟群外景认识它们与地貌的关系。"
	},
	"turkey_avanos": {
		"title": "阿瓦诺斯",
		"scene": "turkey_avanos",
		"region": "卡帕多奇亚",
		"area": "卡帕多奇亚 · 阿瓦诺斯",
		"observation_only": true,
		"info": "阿瓦诺斯位于克孜勒河畔，以陶艺传统闻名。河流带来的红色黏土与当地工坊相连，让陶器成为认识这座小镇日常生活的一条线索。"
	},
	"turkey_red_valley": {
		"title": "红谷",
		"scene": "turkey_red_valley",
		"region": "卡帕多奇亚",
		"area": "卡帕多奇亚 · 红谷",
		"observation_only": true,
		"info": "红谷（Kızılçukur）的凝灰岩层呈现红、粉与赭色，在光线变化中显出不同层次。沟谷与岩壁间保留着岩窟活动的痕迹，本站以山谷全景观赏为主。"
	},
	"turkey_selcuk": {
		"title": "塞尔丘克（Selçuk）",
		"scene": "turkey_selcuk",
		"region": "伊兹密尔",
		"area": "伊兹密尔 · 塞尔丘克",
		"observation_only": false,
		"info": "塞尔丘克是认识以弗所及周边历史的重要城镇。阿亚苏鲁克山上的城堡与圣约翰教堂遗址，把不同历史时期的建筑痕迹带入今天的城镇景观。"
	},
	"turkey_ephesus": {
		"title": "以弗所古城（Ephesus）",
		"scene": "turkey_ephesus",
		"region": "伊兹密尔",
		"area": "伊兹密尔 · 塞尔丘克",
		"observation_only": false,
		"info": "以弗所曾是一座重要的古代港口城市，如今遗址位于塞尔丘克一带。街道、剧场与公共建筑的遗存，让人从石柱和建筑细部中阅读古城的生活层次。"
	},
	"turkey_cesme": {
		"title": "切什梅（Çeşme）",
		"scene": "turkey_cesme",
		"region": "伊兹密尔",
		"area": "伊兹密尔 · 切什梅半岛",
		"observation_only": true,
		"info": "切什梅位于伊兹密尔半岛西端，港湾、海岸与历史城堡共同构成小城的风景。沿着海边远望，爱琴海的蓝色与石砌城墙形成鲜明对照。"
	},
	"turkey_alacati": {
		"title": "阿拉恰特（Alaçatı）",
		"scene": "turkey_alacati",
		"region": "伊兹密尔",
		"area": "伊兹密尔 · 切什梅半岛",
		"observation_only": false,
		"info": "阿拉恰特以石屋、窄街和周边的风车景观闻名。店铺与院落沿街展开，保留着爱琴海沿岸小镇的建筑尺度与生活气息。"
	},
	"turkey_asansor": {
		"title": "大电梯",
		"scene": "turkey_asansor",
		"region": "伊兹密尔",
		"area": "伊兹密尔 · 科纳克",
		"observation_only": true,
		"info": "伊兹密尔的历史大电梯（Asansör）建于 1907 年，用来连接高差明显的街道。砖砌塔身与上方露台，将邻里通行和眺望海湾的城市风景联系起来。"
	},
	"turkey_clock_tower": {
		"title": "市中心钟楼",
		"scene": "turkey_clock_tower",
		"region": "伊兹密尔",
		"area": "伊兹密尔 · 科纳克广场",
		"observation_only": true,
		"info": "市中心钟楼指科纳克广场上的伊兹密尔钟楼，建于 1901 年。纤细塔身、拱券与底部喷泉构成精致的轮廓，是这座爱琴海城市的标志性建筑。"
	},
	"turkey_antalya_airport": {
		"title": "安塔利亚机场",
		"scene": "turkey_antalya_airport",
		"region": "安塔利亚",
		"area": "安塔利亚 · 机场",
		"observation_only": true,
		"info": "安塔利亚机场位于市中心东北方向，是抵达土耳其地中海沿岸的重要门户。本册把机场单独设为抵达站，再依照清单翻向周边古城与海岸景观。"
	},
	"turkey_side": {
		"title": "西代 / Side",
		"scene": "turkey_side",
		"region": "安塔利亚",
		"area": "安塔利亚 · 西代",
		"observation_only": false,
		"info": "西代位于伸向地中海的半岛上，古代城市遗迹与今天的港湾、街区相互交织。本幅从现存柱廊街道认识古城，沿中央地面慢慢走；下一站再走近海边的阿波罗神庙。"
	},
	"turkey_apollo": {
		"title": "阿波罗神庙",
		"scene": "turkey_apollo",
		"region": "安塔利亚",
		"area": "安塔利亚 · 西代",
		"observation_only": true,
		"info": "本册的阿波罗神庙位于西代海岸，现存石柱与残留梁饰面向地中海。它是古代神庙遗址的一部分；画面保留遗址状态，不补建已经消失的殿堂。"
	},
	"turkey_aspendos": {
		"title": "阿斯潘多斯古剧场（Aspendos）",
		"scene": "turkey_aspendos",
		"region": "安塔利亚",
		"area": "安塔利亚 · 塞里克",
		"observation_only": true,
		"info": "阿斯潘多斯古剧场保存了层层看台与高大的舞台建筑，是认识罗马剧场结构的重要实例。从看台望向舞台，可以观察半圆形空间如何围合演出区域。"
	},
	"turkey_perge": {
		"title": "佩尔格古城（Perge）",
		"scene": "turkey_perge",
		"region": "安塔利亚",
		"area": "安塔利亚 · 阿克苏",
		"observation_only": true,
		"info": "佩尔格位于安塔利亚附近的阿克苏一带，保存着柱廊街道、浴场、体育场等遗存。沿着石柱和水道的方向，能够辨认古代公共空间的组织方式。"
	}
}
