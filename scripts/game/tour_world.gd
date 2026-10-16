extends RefCounted
## Screen-space layouts calibrated against the final paintings at 1280 x 720.

static func layout(id: String) -> Dictionary:
	if id.begins_with("angkor_"):
		return preload("res://scripts/game/angkor_world.gd").layout(id)
	var floor := PackedVector2Array([Vector2(130, 500), Vector2(1190, 500), Vector2(1220, 580), Vector2(1100, 704), Vector2(160, 704), Vector2(70, 580)])
	var info := Vector2(345, 490)
	var info_stand := Vector2(430, 570)
	var activity := Vector2(1070, 500)
	var activity_stand := Vector2(980, 600)
	var obstacles: Array[Rect2] = []
	match id:
		"cathedral":
			floor = PackedVector2Array([Vector2(250, 510), Vector2(1110, 510), Vector2(1180, 580), Vector2(1080, 704), Vector2(200, 704), Vector2(140, 580)])
			info = Vector2(345, 516)
			info_stand = Vector2(430, 580)
			activity = Vector2(998, 535)
			activity_stand = Vector2(925, 610)
			obstacles = [Rect2(318, 482, 70, 55), Rect2(952, 474, 110, 94)]
		"book_street":
			floor = PackedVector2Array([Vector2(430, 370), Vector2(900, 370), Vector2(1070, 470), Vector2(1130, 550), Vector2(1060, 704), Vector2(170, 704), Vector2(150, 520), Vector2(340, 450)])
			info = Vector2(346, 410)
			info_stand = Vector2(430, 510)
			activity = Vector2(1120, 425)
			activity_stand = Vector2(1000, 530)
			obstacles = [Rect2(320, 350, 60, 100), Rect2(1030, 360, 190, 120)]
		"city_hall":
			floor = PackedVector2Array([Vector2(120, 470), Vector2(1200, 470), Vector2(1220, 570), Vector2(1100, 704), Vector2(150, 704), Vector2(70, 570)])
			info = Vector2(330, 450)
			info_stand = Vector2(430, 540)
			activity = Vector2(1170, 490)
			activity_stand = Vector2(1080, 590)
			obstacles = [Rect2(302, 420, 60, 62), Rect2(1120, 420, 110, 140)]
		"opera":
			info = Vector2(345, 480)
			info_stand = Vector2(430, 560)
			activity = Vector2(1065, 490)
			activity_stand = Vector2(990, 580)
			obstacles = [Rect2(320, 448, 55, 70), Rect2(1020, 430, 100, 100)]
		"nguyen_hue":
			floor = PackedVector2Array([Vector2(400, 410), Vector2(910, 410), Vector2(1190, 520), Vector2(1230, 590), Vector2(1100, 704), Vector2(170, 704), Vector2(90, 530)])
			info = Vector2(250, 415)
			info_stand = Vector2(365, 510)
			activity = Vector2(1200, 500)
			activity_stand = Vector2(1100, 610)
			obstacles = [Rect2(215, 372, 70, 88), Rect2(1090, 400, 160, 142)]
		"cafe_apartments":
			info = Vector2(360, 480)
			obstacles = [Rect2(334, 452, 62, 65), Rect2(1020, 450, 160, 125)]
		"ben_thanh":
			floor = PackedVector2Array([Vector2(160, 460), Vector2(1150, 460), Vector2(1210, 570), Vector2(1100, 704), Vector2(160, 704), Vector2(70, 570)])
			info = Vector2(320, 460)
			info_stand = Vector2(430, 550)
			activity = Vector2(1195, 450)
			activity_stand = Vector2(1090, 580)
			obstacles = [Rect2(294, 420, 65, 65), Rect2(1125, 380, 145, 135)]
		"fine_arts":
			info = Vector2(390, 475)
			info_stand = Vector2(470, 570)
			activity = Vector2(1040, 480)
			activity_stand = Vector2(950, 590)
			obstacles = [Rect2(362, 430, 62, 80), Rect2(985, 360, 110, 174)]
		"pink_church":
			floor = PackedVector2Array([Vector2(110, 550), Vector2(1190, 550), Vector2(1220, 630), Vector2(1100, 704), Vector2(180, 704), Vector2(70, 630)])
			info = Vector2(375, 530)
			info_stand = Vector2(450, 610)
			activity = Vector2(1170, 560)
			activity_stand = Vector2(1060, 635)
			obstacles = [Rect2(350, 505, 55, 50), Rect2(1110, 470, 130, 155)]
		"war_museum":
			floor = PackedVector2Array([Vector2(130, 480), Vector2(1150, 480), Vector2(1210, 570), Vector2(1100, 704), Vector2(160, 704), Vector2(70, 580)])
			info = Vector2(310, 470)
			info_stand = Vector2(410, 550)
			activity = Vector2(1200, 500)
			activity_stand = Vector2(1090, 610)
			obstacles = [Rect2(280, 430, 60, 82), Rect2(1110, 450, 160, 126)]
	return {"floor": floor, "info": info, "info_stand": info_stand, "activity": activity, "activity_stand": activity_stand, "obstacles": obstacles}
