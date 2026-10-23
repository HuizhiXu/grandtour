extends RefCounted
## Five-city illustrated journey; source references and art prompts live in docs/hexi-art.

const ROUTES: Array[Dictionary] = [
	{
		"journey": "hexi",
		"title": "兰州 · 向西旅行",
		"tab": "兰州",
		"subtitle": "甘肃省博物馆 → 中山桥 → 白塔山 → 黄河母亲雕塑",
		"note": "从黄河之滨启程，先在博物馆认识甘肃，再沿河岸读一读这座城市。兰州作为本册的出发站，与河西走廊各城串联成旅程。",
		"stops": [
			"hexi_gansu_museum",
			"hexi_zhongshan_bridge",
			"hexi_baita_mountain",
			"hexi_yellow_river_mother"
		]
	},
	{
		"journey": "hexi",
		"title": "武威 · 向西旅行",
		"tab": "武威",
		"subtitle": "雷台汉墓 → 武威文庙 → 天梯山石窟 → 武威市博物馆",
		"note": "走进古称凉州的武威，从雷台、文庙到天梯山石窟，再到博物馆，认识河西走廊的历史。天梯山与市区之间采用乘车转场。",
		"stops": [
			"hexi_leitai",
			"hexi_wuwei_confucian_temple",
			"hexi_tiantishan",
			"hexi_wuwei_museum"
		]
	},
	{
		"journey": "hexi",
		"title": "张掖 · 向西旅行",
		"tab": "张掖",
		"subtitle": "七彩丹霞 → 平山湖大峡谷 → 马蹄寺石窟 → 张掖大佛寺",
		"note": "从七彩丹霞与平山湖大峡谷的自然地貌，走向马蹄寺和大佛寺。景点分布在城区及周边县区，可自由选站。",
		"stops": [
			"hexi_rainbow_danxia",
			"hexi_pingshanhu",
			"hexi_mati_temple",
			"hexi_zhangye_dafo"
		]
	},
	{
		"journey": "hexi",
		"title": "嘉峪关 · 向西旅行",
		"tab": "嘉峪关",
		"subtitle": "嘉峪关关城 → 悬壁长城 → 长城第一墩",
		"note": "围绕关城、悬壁长城与长城第一墩，观察明代长城在戈壁、山地和河谷中的不同面貌。",
		"stops": [
			"hexi_jiayuguan_fortress",
			"hexi_overhanging_wall",
			"hexi_first_beacon"
		]
	},
	{
		"journey": "hexi",
		"title": "敦煌 · 向西旅行",
		"tab": "敦煌",
		"subtitle": "莫高窟 → 鸣沙山·月牙泉 → 玉门关 → 阳关 → 敦煌雅丹",
		"note": "从莫高窟与沙漠绿洲走向西线古关和雅丹。以自然地貌结束这段向西的旅行，末站返回本册路线。",
		"stops": [
			"hexi_mogao",
			"hexi_crescent_lake",
			"hexi_yumen_pass",
			"hexi_yang_pass",
			"hexi_yadan"
		]
	}
]

const STOPS: Dictionary = {
	"hexi_gansu_museum": {
		"title": "甘肃省博物馆",
		"scene": "hexi_gansu_museum",
		"region": "甘肃 · 兰州",
		"area": "兰州 · 博物馆",
		"observation_only": true,
		"info": "甘肃省博物馆位于兰州市，是了解甘肃历史与丝绸之路文化的一扇窗口。铜奔马、彩陶与佛教艺术等馆藏，连接起这片土地不同年代的生活。本幅以铜奔马为观赏主题；这件东汉青铜器出土于武威雷台汉墓，原件收藏于兰州的甘肃省博物馆。"
	},
	"hexi_zhongshan_bridge": {
		"title": "中山桥",
		"scene": "hexi_zhongshan_bridge",
		"region": "甘肃 · 兰州",
		"area": "兰州 · 黄河沿岸",
		"observation_only": true,
		"info": "中山桥又称黄河铁桥，钢桁架横跨兰州市区的黄河，将两岸的城市生活连接起来。本幅依据官方发布的俯瞰实景图，观察铁桥斜跨河面的线条，以及北岸金城关街区与白塔山之间的空间关系。桥面和河水在本视角中都作为观景内容。"
	},
	"hexi_baita_mountain": {
		"title": "白塔山",
		"scene": "hexi_baita_mountain",
		"region": "甘肃 · 兰州",
		"area": "兰州 · 黄河沿岸",
		"observation_only": true,
		"info": "白塔山位于黄河北岸，因山上的白塔而得名。山间步道、亭阁与树木层层展开。本幅依据官方实景图，从塔院上方望向黄河与对岸城市，白塔、灰瓦院落和横跨河面的中山桥，构成由近及远的景观层次。"
	},
	"hexi_yellow_river_mother": {
		"title": "黄河母亲雕塑",
		"scene": "hexi_yellow_river_mother",
		"region": "甘肃 · 兰州",
		"area": "兰州 · 黄河沿岸",
		"observation_only": true,
		"info": "黄河母亲雕塑由雕塑家何鄂创作，坐落在兰州黄河南岸。母亲与婴儿的形象，以简练、舒展的线条表达黄河哺育生命的寓意。红花岗岩的温润色泽与背后流动的河水，让这处城市地标多了一份安静的亲切。"
	},
	"hexi_leitai": {
		"title": "雷台汉墓",
		"scene": "hexi_leitai",
		"region": "甘肃 · 武威",
		"area": "武威 · 凉州城区",
		"observation_only": true,
		"info": "雷台汉墓位于武威，是铜奔马等汉代文物的出土地。本幅依据文旅官方实景照片，观察景区今天陈设的放大铜车马仪仗俑阵列，以及门楼、台阶和树木的空间关系。这组户外陈设是当代展示；铜奔马原件收藏于兰州的甘肃省博物馆。"
	},
	"hexi_wuwei_confucian_temple": {
		"title": "武威文庙",
		"scene": "hexi_wuwei_confucian_temple",
		"region": "甘肃 · 武威",
		"area": "武威 · 凉州城区",
		"observation_only": true,
		"info": "武威文庙是凉州古城重要的文教建筑。院落、殿宇与成组匾额，保留着地方教育和礼制文化的印记。本幅选取官方照片中的棂星门视角，朱红立柱、蓝绿斗拱与前方石栏相互映衬，留意三间门楼和古树之间的层次。"
	},
	"hexi_tiantishan": {
		"title": "天梯山石窟",
		"scene": "hexi_tiantishan",
		"region": "甘肃 · 武威",
		"area": "武威 · 黄羊河畔",
		"observation_only": true,
		"info": "天梯山石窟位于武威南部的山地，开凿历史可追溯至北凉时期。石窟与黄羊河水库相邻，大佛、岩壁和水面共同构成鲜明的景观。部分搬迁保护的塑像与壁画可在武威市博物馆了解，本幅保留临水崖壁的观景空间。"
	},
	"hexi_wuwei_museum": {
		"title": "武威市博物馆",
		"scene": "hexi_wuwei_museum",
		"region": "甘肃 · 武威",
		"area": "武威 · 凉州城区",
		"observation_only": true,
		"info": "武威市博物馆通过历史文物和天梯山石窟专题展，呈现凉州与河西走廊的文化联系。汉简、画像砖、器物与石窟艺术，记录着交流往来的细节。本幅依据官方实景照片描绘现代馆舍入口，保留玻璃立面、白色门框与台阶的实际关系，以外观欣赏为主。"
	},
	"hexi_rainbow_danxia": {
		"title": "七彩丹霞",
		"scene": "hexi_rainbow_danxia",
		"region": "甘肃 · 张掖",
		"area": "张掖 · 临泽 · 肃南",
		"observation_only": true,
		"info": "张掖七彩丹霞以连绵丘陵和色彩分明的岩层著称。红、黄、橙与灰白色带顺着山体起伏铺开，光线变化时又呈现不同的层次。本幅采用远眺视角，保留山体的完整轮廓，沿着色带观察大地留下的时间痕迹。"
	},
	"hexi_pingshanhu": {
		"title": "平山湖大峡谷",
		"scene": "hexi_pingshanhu",
		"region": "甘肃 · 张掖",
		"area": "张掖 · 平山湖",
		"observation_only": true,
		"info": "平山湖大峡谷以红褐色岩柱、沟壑与狭长谷道形成壮阔的地貌。风化和流水作用，让岩层显露出不同的形状与纹理。本幅从高处远望峡谷，保留陡崖与谷底的距离感，不把岩壁或沟壑作为人物行走区域。"
	},
	"hexi_mati_temple": {
		"title": "马蹄寺石窟",
		"scene": "hexi_mati_temple",
		"region": "甘肃 · 张掖",
		"area": "张掖 · 肃南",
		"observation_only": true,
		"info": "马蹄寺石窟群位于祁连山北麓，石窟与山地、草地相互依存。三十三天石窟沿崖壁层层展开，窟门、栈道和木构外檐呈现独特的空间关系。本幅从崖外远观，山体与石窟保留为观赏区域。"
	},
	"hexi_zhangye_dafo": {
		"title": "张掖大佛寺",
		"scene": "hexi_zhangye_dafo",
		"region": "甘肃 · 张掖",
		"area": "张掖 · 甘州城区",
		"observation_only": true,
		"info": "张掖大佛寺始建于西夏时期，景区内保存着大佛殿、藏经阁、土塔等建筑，也包含山西会馆等文化空间。巨型卧佛与壁画、经籍，共同见证了丝路上的文化交流。本幅依据景区官方配图选取临水古建视角，欣赏层叠屋檐、两侧楼阁及水中倒影，不把这一幅当作大佛殿内部展示。"
	},
	"hexi_jiayuguan_fortress": {
		"title": "嘉峪关关城",
		"scene": "hexi_jiayuguan_fortress",
		"region": "甘肃 · 嘉峪关",
		"area": "嘉峪关 · 关城",
		"observation_only": true,
		"info": "嘉峪关关城位于河西走廊西部，是明代长城的重要关隘。夯土城墙、城门与高起的楼阁，在戈壁和远山的映衬下格外醒目。本幅从关外广场观察城楼与城垣；这里的转场表达旅行顺序，并非按比例连续的地图。"
	},
	"hexi_overhanging_wall": {
		"title": "悬壁长城",
		"scene": "hexi_overhanging_wall",
		"region": "甘肃 · 嘉峪关",
		"area": "嘉峪关 · 黑山",
		"observation_only": true,
		"info": "悬壁长城依山势起伏，墙体沿陡峭山脊向上延伸，形成仿佛悬挂在山间的轮廓。今天的景观也包含保护修复的成果。本幅从山外远望长城与荒山之间的关系，陡坡、城墙和台阶均保留为观景内容。"
	},
	"hexi_first_beacon": {
		"title": "长城第一墩",
		"scene": "hexi_first_beacon",
		"region": "甘肃 · 嘉峪关",
		"area": "嘉峪关 · 讨赖河畔",
		"observation_only": true,
		"info": "长城第一墩是嘉峪关长城沿线的重要遗存，临近讨赖河峡谷。风化的夯土墩台与深切的河谷，在开阔戈壁中留下鲜明的尺度对比。本幅保留遗址现存的残缺形态，不将它复原成完整城楼；崖边与河谷均不可行走。"
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
		"title": "鸣沙山·月牙泉",
		"scene": "hexi_crescent_lake",
		"region": "甘肃 · 敦煌",
		"area": "敦煌 · 鸣沙山",
		"observation_only": true,
		"info": "鸣沙山与月牙泉共同形成敦煌独特的沙漠绿洲景观。金色沙丘环抱泉水，泉边建筑与植被为辽阔沙海增添了细腻的尺度。本幅依据官方实景图，采用秋日岸边平视角度，保留芦苇、水面、楼阁与沙山的实际层次，不设置穿越泉水或直接攀爬沙丘的行走范围。"
	},
	"hexi_yumen_pass": {
		"title": "玉门关",
		"scene": "hexi_yumen_pass",
		"region": "甘肃 · 敦煌",
		"area": "敦煌 · 敦煌西线",
		"observation_only": true,
		"info": "玉门关遗址位于敦煌西北的戈壁中，现存小方盘城等遗存与汉代交通、防御体系密切相关。风沙磨蚀的夯土墙体，依然勾勒出旧日关塞的轮廓。本幅保留遗址现存状态，走近这段历史，也留意荒漠环境中遗存保护的不易。"
	},
	"hexi_yang_pass": {
		"title": "阳关",
		"scene": "hexi_yang_pass",
		"region": "甘肃 · 敦煌",
		"area": "敦煌 · 敦煌西线",
		"observation_only": true,
		"info": "阳关是古代通往西域的重要关口，古诗中的送别也让它成为熟悉的文化意象。本幅远望墩墩山一带现存的烽燧遗迹，夯土残迹与沙砾地表共同诉说边塞往事。画面不把今天的旅游建筑当作汉代关城复原。"
	},
	"hexi_yadan": {
		"title": "敦煌雅丹",
		"scene": "hexi_yadan",
		"region": "甘肃 · 敦煌",
		"area": "敦煌 · 敦煌西线",
		"observation_only": true,
		"info": "敦煌雅丹以风蚀形成的土丘、垄脊和孤立岩体著称。浅色岩体与深色砾石地表形成对比，远近错落的轮廓有时仿佛一座无人的城。本幅保留自然地貌的形态与尺度，以观景方式结束这一册向西的旅程。"
	}
}
