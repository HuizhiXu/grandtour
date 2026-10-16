extends RefCounted
## Navigation in painting coordinates (1280 x 720); water and ruins stay outside.
static func layout(id: String) -> Dictionary:
	match id:
		"angkor_south_gate":
			return _make([Vector2(520, 480), Vector2(760, 480), Vector2(1110, 708), Vector2(230, 708)], Vector2(640, 650), Vector2(530, 605), Vector2(800, 655), Vector2(640, 675))
		"angkor_bayon":
			return _make([Vector2(100, 535), Vector2(640, 535), Vector2(640, 610), Vector2(100, 610)], Vector2(360, 575), Vector2(200, 575), Vector2(520, 575), Vector2(360, 575))
		"angkor_baphuon":
			return _make([Vector2(790, 560), Vector2(1220, 560), Vector2(1220, 708), Vector2(650, 708)], Vector2(950, 650), Vector2(850, 620), Vector2(1120, 650), Vector2(970, 675))
		"angkor_phimeanakas":
			return _make([Vector2(630, 590), Vector2(1180, 590), Vector2(1210, 708), Vector2(630, 708)], Vector2(760, 650), Vector2(690, 640), Vector2(1010, 655), Vector2(800, 675))
		"angkor_elephants":
			return _make([Vector2(500, 560), Vector2(740, 560), Vector2(1100, 708), Vector2(200, 708)], Vector2(640, 630), Vector2(530, 620), Vector2(800, 665), Vector2(640, 675))
		"angkor_leper_king":
			return _make([Vector2(100, 628), Vector2(1180, 628), Vector2(1180, 708), Vector2(100, 708)], Vector2(640, 668), Vector2(380, 668), Vector2(970, 668), Vector2(640, 668))
		"angkor_royal_palace":
			return _make([Vector2(350, 708), Vector2(1090, 510), Vector2(1090, 708)], Vector2(930, 660), Vector2(730, 650), Vector2(1000, 600), Vector2(950, 675))
		"angkor_victory_gate":
			return _make([Vector2(570, 540), Vector2(710, 540), Vector2(1120, 708), Vector2(170, 708)], Vector2(640, 650), Vector2(510, 645), Vector2(850, 670), Vector2(670, 675))
		"angkor_chau_say":
			return _make([Vector2(520, 600), Vector2(1210, 560), Vector2(1210, 708), Vector2(200, 708)], Vector2(760, 650), Vector2(580, 650), Vector2(1070, 635), Vector2(800, 675))
		"angkor_thommanon":
			return _make([Vector2(260, 600), Vector2(810, 600), Vector2(810, 708), Vector2(260, 708)], Vector2(630, 655), Vector2(430, 650), Vector2(750, 650), Vector2(590, 675))
		"angkor_ta_keo":
			return _make([Vector2(370, 628), Vector2(940, 628), Vector2(940, 708), Vector2(370, 708)], Vector2(650, 674), Vector2(440, 674), Vector2(860, 674), Vector2(650, 674))
	return {}

static func _make(points: Array, spawn: Vector2, info: Vector2, activity: Vector2, record: Vector2, obstacles: Array[Rect2] = []) -> Dictionary:
	return {"floor": PackedVector2Array(points), "spawn": spawn, "info": info + Vector2(0, 24), "info_stand": info, "activity": activity + Vector2(0, 24), "activity_stand": activity, "record": record + Vector2(0, 28), "record_stand": record, "obstacles": obstacles}
