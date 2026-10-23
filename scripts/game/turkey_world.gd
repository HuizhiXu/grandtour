extends RefCounted
## Ground polygons calibrated against the final 1600 x 900 paintings at 1280 x 720.

static func layout(id: String, _view_index: int = 0) -> Dictionary:
	var floor := PackedVector2Array()
	var spawn := Vector2.ZERO
	match id:
		"turkey_hippodrome":
			floor = PackedVector2Array([Vector2(140, 630), Vector2(1140, 630), Vector2(1200, 704), Vector2(90, 704)])
			spawn = Vector2(890, 660)
		"turkey_innocence":
			floor = PackedVector2Array([Vector2(670, 455), Vector2(1000, 455), Vector2(1120, 570), Vector2(1100, 704), Vector2(420, 704), Vector2(420, 565)])
			spawn = Vector2(800, 625)
		"turkey_istiklal":
			floor = PackedVector2Array([Vector2(350, 495), Vector2(630, 486), Vector2(655, 704), Vector2(120, 704), Vector2(120, 596)])
			spawn = Vector2(580, 610)
		"turkey_selcuk":
			floor = PackedVector2Array([Vector2(220, 625), Vector2(980, 625), Vector2(1050, 704), Vector2(175, 704)])
			spawn = Vector2(830, 660)
		"turkey_ephesus":
			floor = PackedVector2Array([Vector2(130, 637), Vector2(1120, 637), Vector2(1220, 704), Vector2(85, 704)])
			spawn = Vector2(820, 670)
		"turkey_alacati":
			floor = PackedVector2Array([Vector2(700, 450), Vector2(820, 470), Vector2(880, 600), Vector2(920, 704), Vector2(370, 704), Vector2(530, 575)])
			spawn = Vector2(700, 625)
		"turkey_side":
			floor = PackedVector2Array([Vector2(425, 480), Vector2(785, 480), Vector2(840, 625), Vector2(840, 704), Vector2(115, 704), Vector2(250, 575)])
			spawn = Vector2(650, 625)
	return {
		"floor": floor, "spawn": spawn, "panorama": floor.is_empty(),
		"obstacles": [] as Array[Rect2], "info": Vector2.ZERO, "info_stand": Vector2.ZERO,
		"activity": Vector2.ZERO, "activity_stand": Vector2.ZERO
	}
