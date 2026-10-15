extends RefCounted
class_name PostcardQuest

enum Stage { MEET_PHOTOGRAPHER, READ_SIGN, WRITE_CARD, POST_CARD, COMPLETE }

const TITLE := "寄出西贡的第一张明信片"
const MESSAGES: Array[String] = [
	"从西贡寄来问候，愿我们都能慢慢看世界。",
	"今天在老邮局前停下脚步，把旅途里的阳光寄给你。",
	"愿下一次漫步，我们能一起听这座城市的故事。",
]
const HINTS: Array[String] = [
	"与广场右侧的旅行摄影师交谈，收下一张空白明信片。",
	"读一读邮局门廊右侧的建筑介绍牌，了解这座老邮局。",
	"走进中央门廊，在大厅右侧的书写台选择一句寄语。",
	"回到广场，点击左侧的旧邮筒，投递写好的明信片。",
	"第一张明信片已寄出。继续漫步，或打开明信片回味这一刻。",
]

var accepted := false
var learned_post_office := false
var message_index := -1
var sent := false


func stage() -> Stage:
	if not accepted:
		return Stage.MEET_PHOTOGRAPHER
	if not learned_post_office:
		return Stage.READ_SIGN
	if message_index < 0:
		return Stage.WRITE_CARD
	return Stage.COMPLETE if sent else Stage.POST_CARD


func accept() -> bool:
	if accepted:
		return false
	accepted = true
	return true


func read_sign() -> bool:
	if learned_post_office:
		return false
	learned_post_office = true
	return true


func write_message(index: int) -> bool:
	if stage() != Stage.WRITE_CARD or index < 0 or index >= MESSAGES.size():
		return false
	message_index = index
	return true


func post() -> bool:
	if stage() != Stage.POST_CARD:
		return false
	sent = true
	return true


func message() -> String:
	return MESSAGES[message_index] if message_index >= 0 and message_index < MESSAGES.size() else ""


func serialize() -> Dictionary:
	return {"accepted": accepted, "learned_post_office": learned_post_office, "message_index": message_index, "sent": sent}


func restore(data: Dictionary) -> void:
	accepted = data.get("accepted", false) == true
	learned_post_office = data.get("learned_post_office", false) == true
	var index: Variant = data.get("message_index", -1)
	message_index = int(index) if index is int or index is float else -1
	if not accepted or not learned_post_office or message_index < 0 or message_index >= MESSAGES.size():
		message_index = -1
	sent = data.get("sent", false) == true and message_index >= 0
