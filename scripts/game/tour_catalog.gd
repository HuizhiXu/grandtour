extends RefCounted
## Scenic stops with introductions; the post office retains its postcard quest.

const Angkor := preload("res://scripts/game/angkor_catalog.gd")
const Datong := preload("res://scripts/game/datong_catalog.gd")
const Hexi := preload("res://scripts/game/hexi_catalog.gd")
const Turkey := preload("res://scripts/game/turkey_catalog.gd")
const JOURNEYS: Array[Dictionary] = [
	{"id": "saigon", "title": "西贡漫步", "region": "越南 · 胡志明市", "subtitle": "街道、建筑与城市日常", "description": "从老邮局的第一张明信片出发。", "cover": "res://assets/game/runtime/saigon-exterior.jpg", "start": "post_office", "routes": [0, 1]},
	{"id": "angkor", "title": "吴哥寻迹", "region": "柬埔寨 · 暹粒", "subtitle": "在树林与石刻之间慢慢走", "description": "沿着石道，翻开古寺与湖畔的风景。", "cover": "res://assets/game/runtime/tour-angkor_wat.jpg", "start": "angkor_south_gate", "routes": [2]},
	{"id": "datong", "title": "大同及周边", "region": "中国 · 山西", "subtitle": "一册晋北古建之旅", "description": "从古城、石窟走向悬空寺与应县木塔。", "cover": "res://assets/game/runtime/tour-datong_hanging_temple.jpg", "start": "datong_city_wall", "routes": [3]},
	{"id": "hexi", "title": "河西走廊", "region": "中国 · 甘肃", "subtitle": "从兰州出发，一路向西", "description": "五座城市，二十九处山河、古建与市井风景。", "cover": "res://assets/game/runtime/tour-hexi_crescent_lake.jpg", "start": "hexi_zhongshan_bridge", "routes": [4, 5, 6, 7, 8], "continue_routes": true},
	{"id": "turkey", "title": "土耳其", "region": "土耳其", "subtitle": "海峡、高原与地中海", "description": "四个地区，三十站城市、山谷与古城风景。", "cover": "res://assets/game/runtime/tour-turkey_bosphorus.jpg", "start": "turkey_bosphorus", "routes": [9, 10, 11, 12], "continue_routes": true},
]
const ROUTES: Array[Dictionary] = [
	{"title": "经典建筑与城市漫步", "subtitle": "独立宫 → 红教堂 → 中央邮局 → 书街 → 市政厅 → 歌剧院 → 阮惠步行街 → 咖啡公寓", "note": "沿城市中心慢慢走，从历史建筑走向当代街头。教堂、市政厅和歌剧院以外观欣赏为主。", "stops": ["palace", "cathedral", "post_office", "book_street", "city_hall", "opera", "nguyen_hue", "cafe_apartments"]},
	{"title": "市场、艺术与历史", "subtitle": "滨城市场 → 美术馆 → 粉红教堂 → 战争遗迹博物馆", "note": "市场与美术馆相邻；粉红教堂较远，可乘车前往。可自由选站，也可把战争遗迹博物馆与独立宫一起参观，减少折返。", "stops": ["ben_thanh", "fine_arts", "pink_church", "war_museum"]},
	Angkor.ROUTE,
	Datong.ROUTE,
	Hexi.ROUTES[0],
	Hexi.ROUTES[1],
	Hexi.ROUTES[2],
	Hexi.ROUTES[3],
	Hexi.ROUTES[4],
	Turkey.ROUTES[0],
	Turkey.ROUTES[1],
	Turkey.ROUTES[2],
	Turkey.ROUTES[3],
]

static var STOPS: Dictionary = SAIGON_STOPS.merged(Angkor.STOPS).merged(Datong.STOPS).merged(Hexi.STOPS).merged(Turkey.STOPS)

const SAIGON_STOPS: Dictionary = {
	"palace": {"title": "独立宫", "scene": "palace_garden", "info": "独立宫由建筑师吴曰树（Ngô Viết Thụ）设计，于 1966 年落成。横向舒展的楼体与立面遮阳构件，将现代建筑语言与东方意象结合在一起。"},
	"post_office": {"title": "中央邮局", "scene": "outdoor"},
	"cathedral": {
		"title": "红教堂 · 圣母大教堂", "scene": "cathedral",
		"info": "红砖外墙、成对的钟塔和拱形入口，让西贡圣母大教堂在城市中心格外醒目。它与中央邮局相望，是认识这片街区的一个好起点。",
	},
	"book_street": {
		"title": "阮文平书街", "scene": "book_street",
		"info": "阮文平书街紧邻中央邮局，是一条被书店、书摊和树荫围起来的步行空间。建筑之间，一小段安静的阅读时光也能成为旅途的目的地。",
	},
	"city_hall": {
		"title": "胡志明市市政厅", "scene": "city_hall",
		"info": "浅色装饰、对称的立面与中央塔楼，是市政厅容易辨认的建筑特征。它位于阮惠步行街的一端，与街道上的城市生活遥相呼应。",
	},
	"opera": {
		"title": "西贡歌剧院", "scene": "opera",
		"info": "西贡歌剧院的浅色立面、装饰雕塑与正面台阶，构成一处适合驻足观察的城市舞台。拱形入口与周围街道的现代建筑，形成有趣的对照。",
	},
	"nguyen_hue": {
		"title": "阮惠步行街", "scene": "nguyen_hue",
		"info": "阮惠步行街是一条宽阔的城市步行空间，两侧连接高楼、商店与咖啡馆。沿着它漫步，旧建筑的轮廓与当代都市的天际线会同时进入视野。",
	},
	"cafe_apartments": {
		"title": "咖啡公寓 · 42 号", "scene": "cafe_apartments",
		"info": "阮惠街的 42 号公寓以层层阳台和各具个性的小店而闻名。旧公寓的格子立面，承载了咖啡馆、店铺与城市日常交织的景象。",
	},
	"ben_thanh": {
		"title": "滨城市场", "scene": "ben_thanh",
		"info": "滨城市场的钟楼入口，是西贡市中心鲜明的地标。市场把食物、货物和日常交流聚在一起，也是观察城市生活的一扇窗口。",
	},
	"fine_arts": {
		"title": "胡志明市美术馆", "scene": "fine_arts",
		"info": "胡志明市美术馆位于一组富有特色的旧建筑中。暖黄色墙面、窗廊与庭院，本身就让人想放慢脚步；馆藏则呈现越南艺术的多种面貌。",
	},
	"pink_church": {
		"title": "粉红教堂 · 新定教堂", "scene": "pink_church",
		"info": "新定教堂常被称为粉红教堂。粉色墙面、浅色装饰和高高的钟塔，让它成为这条路线中独特的一站。",
	},
	"war_museum": {
		"title": "战争遗迹博物馆", "scene": "war_museum",
		"info": "战争遗迹博物馆通过历史资料、影像与实物，让参观者了解战争及其长期影响。来到这里，需要留出认真阅读与思考的时间。",
	},
}

static func stop_for_scene(scene_id: String) -> String:
	if scene_id == "indoor": return "post_office"
	if scene_id == "palace_hall": return "palace"
	for id: String in STOPS:
		if STOPS[id].scene == scene_id: return id
	return ""

static func route_for_stop(id: String) -> int:
	for index in range(ROUTES.size()):
		if id in ROUTES[index].stops: return index
	return 0

static func is_new_stop(id: String) -> bool:
	return STOPS.has(id) and id not in ["palace", "post_office"]

static func views(id: String) -> Array:
	return STOPS.get(id, {}).get("views", [])

static func background_path(id: String, view_index: int = 0) -> String:
	var perspectives := views(id)
	if not perspectives.is_empty():
		return "res://assets/game/runtime/tour-%s.jpg" % perspectives[clampi(view_index, 0, perspectives.size() - 1)].art
	return "res://assets/game/runtime/tour-%s.jpg" % id


static func journey(id: String) -> Dictionary:
	for entry: Dictionary in JOURNEYS:
		if entry.id == id: return entry
	return {}


static func journey_for_route(route_index: int) -> Dictionary:
	for entry: Dictionary in JOURNEYS:
		if route_index in entry.routes: return entry
	return JOURNEYS[0]


static func journey_for_stop(id: String) -> Dictionary:
	return journey_for_route(route_for_stop(id))
