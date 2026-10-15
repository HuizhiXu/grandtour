extends RefCounted
## Independent progress for the second stop; old postcard saves remain valid.

const TITLE := "参观独立宫"
const HINTS: Array[String] = [
	"沿庭院右侧步道，阅读独立宫的建筑介绍牌。",
	"走近左侧观景牌，看看立面的光影与庭院。",
	"从中央入口走进大厅，阅读接待厅前的展览说明。",
	"到大厅右侧的参观台，为这一站留下旅行纪念。",
	"独立宫参观完成。可以回到庭院漫步，或返回中央邮局。",
]
const INFO := "独立宫由建筑师吴曰树（Ngô Viết Thụ）设计，于 1966 年落成。横向舒展的楼体与立面遮阳构件，将现代建筑语言与东方意象结合在一起。\n\n沿着庭院步道走近，留意立面在阳光下投出的层层阴影。"
const VIEW := "从庭院回望，细长的混凝土遮阳构件像一道通透的帘幕。平直的屋顶、重复的竖向线条，与眼前的草坪和喷泉构成安静的节奏。\n\nArchie 在树荫边停了一会儿，把这一刻记进旅途。"
const EXHIBIT := "独立宫曾是越南共和国总统的居所与办公地点。1975 年 4 月 30 日，这里见证了越南战争结束的重要历史时刻。\n\n今天，建筑与保留下来的室内空间向参观者讲述这段历史。请在参观线外驻足观看。"

var architecture_read := false
var garden_viewed := false
var exhibit_read := false
var souvenir_collected := false


func stage() -> int:
	if not architecture_read:
		return 0
	if not garden_viewed:
		return 1
	if not exhibit_read:
		return 2
	return 4 if souvenir_collected else 3


func record(stop: String) -> bool:
	match stop:
		"architecture": architecture_read = true
		"garden": garden_viewed = true
		"exhibit": exhibit_read = true
		"souvenir":
			if stage() != 3:
				return false
			souvenir_collected = true
		_: return false
	return true


func serialize() -> Dictionary:
	return {"architecture_read": architecture_read, "garden_viewed": garden_viewed, "exhibit_read": exhibit_read, "souvenir_collected": souvenir_collected}


func restore(data: Dictionary) -> void:
	architecture_read = data.get("architecture_read", false) == true
	garden_viewed = data.get("garden_viewed", false) == true
	exhibit_read = data.get("exhibit_read", false) == true
	souvenir_collected = data.get("souvenir_collected", false) == true and architecture_read and garden_viewed and exhibit_read
