extends RefCounted
## Datong and the nearby Yingxian stop; paintings follow official site photographs.

const ROUTE: Dictionary = {
	"journey": "datong", "title": "大同及周边 · 晋北古建之旅", "tab": "晋北古建",
	"subtitle": "古城墙 → 华严寺 → 善化寺 → 九龙壁 → 云冈石窟 → 悬空寺 → 应县木塔",
	"note": "从古城的砖瓦走向山间的木构，再到应县仰望古塔。可按绘本顺序浏览，也可自由选站；城外及应县之间采用乘车转场。应县木塔位于朔州市应县，是本册的周边延伸站。",
	"stops": ["datong_city_wall", "datong_huayan", "datong_shanhua", "datong_nine_dragon_wall", "datong_yungang", "datong_hanging_temple", "yingxian_wooden_pagoda"]
}

const STOPS: Dictionary = {
	"datong_city_wall": {
		"title": "大同古城墙", "scene": "datong_city_wall", "region": "山西 · 大同", "area": "大同古城", "observation_only": true,
		"info": "大同古城墙在历代城垣基础上形成，今天看到的城墙也包含保护修复的成果。灰砖城垣、错落的城楼与护城河，勾勒出古城的轮廓。这一幅从城外临水处远望，留意城墙与水中倒影之间的呼应。"
	},
	"datong_huayan": {
		"title": "华严寺", "scene": "datong_huayan", "region": "山西 · 大同", "area": "大同古城", "observation_only": true,
		"info": "华严寺位于大同古城内，是认识辽金建筑的重要一站。大雄宝殿舒展的屋顶、厚重的殿身，与院落间的灰瓦和树荫组成层次丰富的景象。这一幅采用俯瞰视角，适合观察殿宇、院墙与庭园的关系。"
	},
	"datong_shanhua": {
		"title": "善化寺", "scene": "datong_shanhua", "region": "山西 · 大同", "area": "大同古城", "observation_only": true,
		"info": "善化寺保存着珍贵的辽金木构建筑与塑像，山门、三圣殿和大雄宝殿沿中轴展开。本幅选取寺院西园池畔的园林视角：亭阁、长廊与石栏映在水中，让古建之旅也有一段安静的停留。池畔园林与寺内古代殿堂属于不同的观赏空间。"
	},
	"datong_nine_dragon_wall": {
		"title": "九龙壁", "scene": "datong_nine_dragon_wall", "region": "山西 · 大同", "area": "大同古城",
		"info": "大同九龙壁是一座明代琉璃照壁，原位于代王府前。九条彩龙在蓝绿色琉璃与云水纹样间舒展，中央黄色的龙尤其醒目。沿前方铺地慢慢走，观察浮雕的起伏、琉璃的色彩，以及窄池中的倒影。"
	},
	"datong_yungang": {
		"title": "云冈石窟", "scene": "datong_yungang", "region": "山西 · 大同", "area": "云冈",
		"info": "云冈石窟开凿于北魏时期，石刻艺术在这里与山崖融为一体。本幅是第 20 窟露天大佛：宽阔的面容、袈裟的衣纹与风化的岩壁，记录着时间留下的痕迹。人物只在护栏外的参观步道漫步，石刻和崖壁保留为观赏区域。"
	},
	"datong_hanging_temple": {
		"title": "悬空寺", "scene": "datong_hanging_temple", "region": "山西 · 浑源", "area": "浑源", "observation_only": true,
		"info": "悬空寺位于大同市浑源县，依翠屏峰崖壁而建。木构楼阁、狭长栈道与岩壁彼此相接，形成高低错落的轮廓。嵌入山体的横梁是理解其结构的重要线索；从远处观察，也能看见细长立柱与层层屋檐之间的关系。"
	},
	"yingxian_wooden_pagoda": {
		"title": "应县木塔", "scene": "yingxian_wooden_pagoda", "region": "山西 · 朔州应县", "area": "应县", "observation_only": true,
		"info": "应县木塔又名佛宫寺释迦塔，位于朔州市应县，作为大同之旅的周边一站收进本册。塔身为八角形，外观五层六檐，层层斗拱与木构构件承接起高大的体量。这一幅从较高处观察，完整呈现塔刹、屋檐、塔基与周围院落。"
	}
}
