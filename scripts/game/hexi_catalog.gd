extends RefCounted
## User-specified 29-stop itinerary; official-photo provenance: docs/hexi-art/production-v2.json.

const ROUTES: Array[Dictionary] = [
	{
		"journey": "hexi",
		"title": "兰州 · 向西旅行",
		"tab": "兰州",
		"subtitle": "中山桥 → 正宁路夜市 → 甘肃省博物馆",
		"note": "从中山桥看黄河，走进正宁路夜市，再到甘肃省博物馆认识这片土地。按照本册顺序，下一站从兰州前往武威。",
		"stops": [
			"hexi_zhongshan_bridge",
			"hexi_zhengning_market",
			"hexi_gansu_museum"
		]
	},
	{
		"journey": "hexi",
		"title": "武威 · 向西旅行",
		"tab": "武威",
		"subtitle": "乌鞘岭 → 天梯山石窟 → 白塔寺 → 南城门楼 → 鸠摩罗什寺 → 西夏博物馆 → 武威文庙 → 大云寺古钟楼 → 武威市博物馆 → 海藏寺",
		"note": "从天祝乌鞘岭进入武威，沿天梯山石窟、白塔寺走向凉州城区的古建与博物馆。本页共十站，可上下滚动查看；景点之间通过翻页转场。",
		"stops": [
			"hexi_wushaoling",
			"hexi_tiantishan",
			"hexi_baita_temple",
			"hexi_south_gate",
			"hexi_kumarajiva_temple",
			"hexi_xixia_museum",
			"hexi_wuwei_confucian_temple",
			"hexi_dayun_bell_tower",
			"hexi_wuwei_museum",
			"hexi_haizang_temple"
		]
	},
	{
		"journey": "hexi",
		"title": "张掖 · 向西旅行",
		"tab": "张掖",
		"subtitle": "马蹄寺 → 金塔寺 → 镇远楼 → 平山湖大峡谷 → 七彩丹霞 → 大佛寺",
		"note": "先看马蹄寺与金塔寺的崖壁石窟，再到镇远楼；随后翻阅平山湖大峡谷、七彩丹霞和大佛寺。景点分布于城区及周边县区，可自由选站。",
		"stops": [
			"hexi_mati_temple",
			"hexi_jinta_temple",
			"hexi_zhenyuan_tower",
			"hexi_pingshanhu",
			"hexi_rainbow_danxia",
			"hexi_zhangye_dafo"
		]
	},
	{
		"journey": "hexi",
		"title": "嘉峪关 · 向西旅行",
		"tab": "嘉峪关",
		"subtitle": "嘉峪关 → 长城第一墩 → 悬壁长城",
		"note": "从嘉峪关关城出发，依次翻阅长城第一墩与悬壁长城，观察明代长城在戈壁、河谷和山地中的不同面貌。",
		"stops": [
			"hexi_jiayuguan_fortress",
			"hexi_first_beacon",
			"hexi_overhanging_wall"
		]
	},
	{
		"journey": "hexi",
		"title": "敦煌 · 向西旅行",
		"tab": "敦煌",
		"subtitle": "莫高窟 → 鸣沙山月牙泉 → 敦煌夜市 → 西千佛洞 → 阳关 → 玉门关 → 雅丹魔鬼城",
		"note": "从莫高窟、鸣沙山月牙泉走进敦煌夜市，再沿西千佛洞、阳关、玉门关前往雅丹魔鬼城。末站返回本册路线，各站均可自由选看。",
		"stops": [
			"hexi_mogao",
			"hexi_crescent_lake",
			"hexi_dunhuang_market",
			"hexi_west_thousand_buddha",
			"hexi_yang_pass",
			"hexi_yumen_pass",
			"hexi_yadan"
		]
	}
]

const STOPS: Dictionary = {
	"hexi_zhongshan_bridge": {
		"title": "中山桥",
		"scene": "hexi_zhongshan_bridge",
		"region": "甘肃 · 兰州",
		"area": "兰州 · 黄河沿岸",
		"observation_only": true,
		"info": "中山桥又称黄河铁桥，钢桁架横跨兰州市区的黄河，将两岸的城市生活连接起来。本幅依据官方发布的俯瞰实景图，观察铁桥斜跨河面的线条，以及北岸金城关街区与白塔山之间的空间关系。桥面和河水在本视角中都作为观景内容。"
	},
	"hexi_zhengning_market": {
		"area": "兰州 · 正宁路",
		"info": "正宁路夜市位于兰州市城关区，小吃摊位与往来食客构成了兰州夜生活的一角。牛奶鸡蛋醪糟、烤肉和酿皮等风味，让这条街充满烟火气。本幅依据新华社记者在正宁路小吃夜市拍摄的官方配图，保留摊位、灯光和食客之间的真实空间关系。",
		"title": "正宁路夜市",
		"scene": "hexi_zhengning_market",
		"region": "甘肃 · 兰州",
		"observation_only": true
	},
	"hexi_gansu_museum": {
		"title": "甘肃省博物馆",
		"scene": "hexi_gansu_museum",
		"region": "甘肃 · 兰州",
		"area": "兰州 · 博物馆",
		"observation_only": true,
		"info": "甘肃省博物馆位于兰州市，是了解甘肃历史与丝绸之路文化的一扇窗口。铜奔马、彩陶与佛教艺术等馆藏，连接起这片土地不同年代的生活。本幅以铜奔马为观赏主题；这件东汉青铜器出土于武威雷台汉墓，原件收藏于兰州的甘肃省博物馆。"
	},
	"hexi_wushaoling": {
		"area": "武威 · 天祝乌鞘岭",
		"info": "乌鞘岭位于武威市天祝藏族自治县，是河西走廊东端的重要山岭。连绵草甸、远方雪峰和长城遗迹，让这里成为认识河西地理与丝路历史的一处窗口。本幅依据官方实景照片，保留起伏山坡、残雪与远山的实际层次，以静观山景为主。",
		"title": "乌鞘岭",
		"scene": "hexi_wushaoling",
		"region": "甘肃 · 武威",
		"observation_only": true
	},
	"hexi_tiantishan": {
		"title": "天梯山石窟",
		"scene": "hexi_tiantishan",
		"region": "甘肃 · 武威",
		"area": "武威 · 黄羊河畔",
		"observation_only": true,
		"info": "天梯山石窟位于武威南部的山地，开凿历史可追溯至北凉时期。石窟与黄羊河水库相邻，大佛、岩壁和水面共同构成鲜明的景观。部分搬迁保护的塑像与壁画可在武威市博物馆了解，本幅保留临水崖壁的观景空间。"
	},
	"hexi_baita_temple": {
		"area": "武威 · 白塔寺",
		"info": "武威白塔寺与凉州会盟的历史密切相连，今天的凉州会盟纪念馆依托白塔寺遗址而建。景区以遗址保护、塔林与纪念展示呈现相关历史。本幅选取官方照片中的白塔外景，保留松柏、塔身和庭院的实际关系；画面中的现今纪念景观不作为古代原构复原。",
		"title": "白塔寺",
		"scene": "hexi_baita_temple",
		"region": "甘肃 · 武威",
		"observation_only": true
	},
	"hexi_south_gate": {
		"area": "武威 · 凉州城区",
		"info": "南城门楼又称昭武门，是凉州城区鲜明的城市地标。厚重台基、拱形门洞与层叠屋檐，连接着古城记忆和今天的广场生活。本幅依据文旅官方发布的夜景照片，欣赏灯光勾勒出的城楼轮廓与三个门洞，保留今天修缮重建后的实际面貌。",
		"title": "南城门楼",
		"scene": "hexi_south_gate",
		"region": "甘肃 · 武威",
		"observation_only": true
	},
	"hexi_kumarajiva_temple": {
		"area": "武威 · 凉州城区",
		"info": "鸠摩罗什寺纪念佛经翻译家鸠摩罗什与凉州的历史联系，寺内的塔、殿宇与纪念展示，让人了解佛教沿丝绸之路传播的故事。本幅依据甘肃省文化和旅游厅提供的冬日实景照片，保留殿宇、砖塔与雪中松柏的位置，以庭院外观欣赏为主。",
		"title": "鸠摩罗什寺",
		"scene": "hexi_kumarajiva_temple",
		"region": "甘肃 · 武威",
		"observation_only": true
	},
	"hexi_xixia_museum": {
		"area": "武威 · 凉州城区",
		"info": "西夏博物馆毗邻武威文庙，以西夏文物展示凉州在这一历史时期的文化面貌。重修护国寺感应塔碑是馆内的重要藏品，一面刻西夏文，一面刻汉文。本幅依据官方发布的西夏碑实物照片，观察碑体、石座和保护陈列的实际形态，以文物观赏为主。",
		"title": "西夏博物馆",
		"scene": "hexi_xixia_museum",
		"region": "甘肃 · 武威",
		"observation_only": true
	},
	"hexi_wuwei_confucian_temple": {
		"title": "武威文庙",
		"scene": "hexi_wuwei_confucian_temple",
		"region": "甘肃 · 武威",
		"area": "武威 · 凉州城区",
		"observation_only": true,
		"info": "武威文庙是凉州古城重要的文教建筑。院落、殿宇与成组匾额，保留着地方教育和礼制文化的印记。本幅选取官方照片中的棂星门视角，朱红立柱、蓝绿斗拱与前方石栏相互映衬，留意三间门楼和古树之间的层次。"
	},
	"hexi_dayun_bell_tower": {
		"area": "武威 · 凉州城区",
		"info": "大云寺古钟楼与寺内唐钟，承载着凉州古城的历史记忆，“大云晓钟”也成为人们熟悉的地方文化意象。本幅选取官方实景照片中的门楼侧前方视角，保留砖砌高台、钟楼、石阶与红灯笼的关系，不把现存建筑改画成想象中的古寺。",
		"title": "大云寺古钟楼",
		"scene": "hexi_dayun_bell_tower",
		"region": "甘肃 · 武威",
		"observation_only": true
	},
	"hexi_wuwei_museum": {
		"title": "武威市博物馆",
		"scene": "hexi_wuwei_museum",
		"region": "甘肃 · 武威",
		"area": "武威 · 凉州城区",
		"observation_only": true,
		"info": "武威市博物馆通过历史文物和天梯山石窟专题展，呈现凉州与河西走廊的文化联系。汉简、画像砖、器物与石窟艺术，记录着交流往来的细节。本幅依据官方实景照片描绘现代馆舍入口，保留玻璃立面、白色门框与台阶的实际关系，以外观欣赏为主。"
	},
	"hexi_haizang_temple": {
		"area": "武威 · 凉州城区",
		"info": "海藏寺是武威的古建筑遗存。牌坊、殿宇和院内松柏，保留着这座寺院独特的空间层次。本幅依据甘肃省文化和旅游厅提供的正面实景照片，观察木构牌坊的斗拱、屋檐及后方殿门，按照片中的现存面貌呈现。",
		"title": "海藏寺",
		"scene": "hexi_haizang_temple",
		"region": "甘肃 · 武威",
		"observation_only": true
	},
	"hexi_mati_temple": {
		"title": "马蹄寺",
		"scene": "hexi_mati_temple",
		"region": "甘肃 · 张掖",
		"area": "张掖 · 肃南",
		"observation_only": true,
		"info": "马蹄寺石窟群位于祁连山北麓，石窟与山地、草地相互依存。三十三天石窟沿崖壁层层展开，窟门、栈道和木构外檐呈现独特的空间关系。本幅从崖外远观，山体与石窟保留为观赏区域。"
	},
	"hexi_jinta_temple": {
		"area": "张掖 · 肃南",
		"info": "金塔寺属于马蹄寺石窟群，位于祁连山北麓的山谷中，以富于立体感的高肉雕泥塑飞天等石窟艺术闻名。本幅采用官方报道中的航拍外景，保留红砂岩崖壁、石窟入口、栈道和林木之间的实际关系；洞窟内的彩塑与壁画不在这一幅中模拟。",
		"title": "金塔寺",
		"scene": "hexi_jinta_temple",
		"region": "甘肃 · 张掖",
		"observation_only": true
	},
	"hexi_zhenyuan_tower": {
		"area": "张掖 · 甘州城区",
		"info": "镇远楼又称张掖钟鼓楼，位于张掖城区四条大街的交汇处。青砖楼台托起木构楼阁，四向门洞与街道相接，是古城的重要标志。本幅依据张掖市政府发布的城市实景照片，从高处观察鼓楼、环绕道路与远方山脉，保留今天的城市环境。",
		"title": "镇远楼",
		"scene": "hexi_zhenyuan_tower",
		"region": "甘肃 · 张掖",
		"observation_only": true
	},
	"hexi_pingshanhu": {
		"title": "平山湖大峡谷",
		"scene": "hexi_pingshanhu",
		"region": "甘肃 · 张掖",
		"area": "张掖 · 平山湖",
		"observation_only": true,
		"info": "平山湖大峡谷以红褐色岩柱、沟壑与狭长谷道形成壮阔的地貌。风化和流水作用，让岩层显露出不同的形状与纹理。本幅从高处远望峡谷，保留陡崖与谷底的距离感，不把岩壁或沟壑作为人物行走区域。"
	},
	"hexi_rainbow_danxia": {
		"title": "七彩丹霞",
		"scene": "hexi_rainbow_danxia",
		"region": "甘肃 · 张掖",
		"area": "张掖 · 临泽 · 肃南",
		"observation_only": true,
		"info": "张掖七彩丹霞以连绵丘陵和色彩分明的岩层著称。红、黄、橙与灰白色带顺着山体起伏铺开，光线变化时又呈现不同的层次。本幅采用远眺视角，保留山体的完整轮廓，沿着色带观察大地留下的时间痕迹。"
	},
	"hexi_zhangye_dafo": {
		"title": "大佛寺",
		"scene": "hexi_zhangye_dafo",
		"region": "甘肃 · 张掖",
		"area": "张掖 · 甘州城区",
		"observation_only": true,
		"info": "张掖大佛寺始建于西夏时期，景区内保存着大佛殿、藏经阁、土塔等建筑，也包含山西会馆等文化空间。巨型卧佛与壁画、经籍，共同见证了丝路上的文化交流。本幅依据景区官方配图选取临水古建视角，欣赏层叠屋檐、两侧楼阁及水中倒影，不把这一幅当作大佛殿内部展示。"
	},
	"hexi_jiayuguan_fortress": {
		"title": "嘉峪关",
		"scene": "hexi_jiayuguan_fortress",
		"region": "甘肃 · 嘉峪关",
		"area": "嘉峪关 · 关城",
		"observation_only": true,
		"info": "嘉峪关关城位于河西走廊西部，是明代长城的重要关隘。夯土城墙、城门与高起的楼阁，在戈壁和远山的映衬下格外醒目。本幅从关外广场观察城楼与城垣；这里的转场表达旅行顺序，并非按比例连续的地图。"
	},
	"hexi_first_beacon": {
		"title": "长城第一墩",
		"scene": "hexi_first_beacon",
		"region": "甘肃 · 嘉峪关",
		"area": "嘉峪关 · 讨赖河畔",
		"observation_only": true,
		"info": "长城第一墩是嘉峪关长城沿线的重要遗存，临近讨赖河峡谷。风化的夯土墩台与深切的河谷，在开阔戈壁中留下鲜明的尺度对比。本幅保留遗址现存的残缺形态，不将它复原成完整城楼；崖边与河谷均不可行走。"
	},
	"hexi_overhanging_wall": {
		"title": "悬壁长城",
		"scene": "hexi_overhanging_wall",
		"region": "甘肃 · 嘉峪关",
		"area": "嘉峪关 · 黑山",
		"observation_only": true,
		"info": "悬壁长城依山势起伏，墙体沿陡峭山脊向上延伸，形成仿佛悬挂在山间的轮廓。今天的景观也包含保护修复的成果。本幅从山外远望长城与荒山之间的关系，陡坡、城墙和台阶均保留为观景内容。"
	},
	"hexi_mogao": {
		"title": "莫高窟",
		"scene": "hexi_mogao",
		"region": "甘肃 · 敦煌",
		"area": "敦煌 · 莫高窟",
		"observation_only": true,
		"info": "莫高窟位于敦煌东南的崖壁间，历代营造的洞窟保存着珍贵的壁画与彩塑。本幅选取第九十六窟九层楼的外观，红色木构依崖而立，是窟区鲜明的标志。画册以外观观赏为主，不模拟洞窟内部，也不代表现实中的开放安排。"
	},
	"hexi_crescent_lake": {
		"title": "鸣沙山月牙泉",
		"scene": "hexi_crescent_lake",
		"region": "甘肃 · 敦煌",
		"area": "敦煌 · 鸣沙山",
		"observation_only": true,
		"info": "鸣沙山与月牙泉共同形成敦煌独特的沙漠绿洲景观。金色沙丘环抱泉水，泉边建筑与植被为辽阔沙海增添了细腻的尺度。本幅依据官方实景图，采用秋日岸边平视角度，保留芦苇、水面、楼阁与沙山的实际层次，不设置穿越泉水或直接攀爬沙丘的行走范围。"
	},
	"hexi_dunhuang_market": {
		"area": "敦煌 · 沙州城区",
		"info": "敦煌夜市也称沙洲夜市，是品尝地方小吃、感受城市夜生活的一处街区。灯光、商铺和融入敦煌文化元素的当代建筑，共同构成热闹的市井景观。本幅依据官方报道的夜市实景，保留廊桥、阶梯、灯笼与摊位的位置，不把今天的商业街区当作唐代古建。",
		"title": "敦煌夜市",
		"scene": "hexi_dunhuang_market",
		"region": "甘肃 · 敦煌",
		"observation_only": true
	},
	"hexi_west_thousand_buddha": {
		"area": "敦煌 · 党河河谷",
		"info": "西千佛洞位于敦煌西南的党河河谷，因在莫高窟以西而得名，是敦煌石窟艺术的重要组成部分。洞窟沿河谷崖壁开凿，壁画与彩塑保存着不同时期的艺术信息。本幅依据敦煌研究院发布的窟区外景，保留经过保护加固的崖壁、窟门、栈道和树木，不模拟洞窟内部。",
		"title": "西千佛洞",
		"scene": "hexi_west_thousand_buddha",
		"region": "甘肃 · 敦煌",
		"observation_only": true
	},
	"hexi_yang_pass": {
		"title": "阳关",
		"scene": "hexi_yang_pass",
		"region": "甘肃 · 敦煌",
		"area": "敦煌 · 敦煌西线",
		"observation_only": true,
		"info": "阳关是古代通往西域的重要关口，古诗中的送别也让它成为熟悉的文化意象。本幅远望墩墩山一带现存的烽燧遗迹，夯土残迹与沙砾地表共同诉说边塞往事。画面不把今天的旅游建筑当作汉代关城复原。"
	},
	"hexi_yumen_pass": {
		"title": "玉门关",
		"scene": "hexi_yumen_pass",
		"region": "甘肃 · 敦煌",
		"area": "敦煌 · 敦煌西线",
		"observation_only": true,
		"info": "玉门关遗址位于敦煌西北的戈壁中，现存小方盘城等遗存与汉代交通、防御体系密切相关。风沙磨蚀的夯土墙体，依然勾勒出旧日关塞的轮廓。本幅保留遗址现存状态，走近这段历史，也留意荒漠环境中遗存保护的不易。"
	},
	"hexi_yadan": {
		"title": "雅丹魔鬼城",
		"scene": "hexi_yadan",
		"region": "甘肃 · 敦煌",
		"area": "敦煌 · 敦煌西线",
		"observation_only": true,
		"info": "敦煌雅丹以风蚀形成的土丘、垄脊和孤立岩体著称。浅色岩体与深色砾石地表形成对比，远近错落的轮廓有时仿佛一座无人的城。本幅保留自然地貌的形态与尺度，以观景方式结束这一册向西的旅程。"
	}
}
