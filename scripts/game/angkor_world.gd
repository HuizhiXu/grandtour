extends RefCounted
## Navigation in painting coordinates (1280 x 720); water and ruins stay outside.
static func layout(id: String, view_index: int = 0) -> Dictionary:
	if id == "angkor_preah_ko":
		if view_index == 1:
			# Foreground below the courtyard sculptures, clear of bases and shrine steps.
			return _make([Vector2(500, 625), Vector2(1100, 640), Vector2(1150, 720), Vector2(400, 720)], Vector2(720, 680), Vector2(550, 670), Vector2(950, 680), Vector2(720, 685))
		# Left foreground only; the central bull and platform stay outside navigation.
		return _make([Vector2(120, 615), Vector2(550, 615), Vector2(550, 720), Vector2(100, 720)], Vector2(380, 650), Vector2(220, 650), Vector2(470, 650), Vector2(350, 650))
	if id == "angkor_beng_mealea":
		# Elevated path and rubble references do not document a walkable foreground.
		var panorama := _make([], Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO)
		panorama["panorama"] = true
		return panorama
	if id == "angkor_banteay_srei":
		if view_index == 1:
			# All foreground is pond water; the far bank is observation only.
			var panorama := _make([], Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO)
			panorama["panorama"] = true
			return panorama
		# Central approach only, clear of stone posts, ropes and closed doorways.
		return _make([Vector2(430, 570), Vector2(700, 570), Vector2(725, 708), Vector2(360, 708)], Vector2(560, 650), Vector2(480, 625), Vector2(650, 650), Vector2(560, 680))
	if id == "angkor_kravan":
		if view_index == 1:
			# The relief fills the frame; no chamber floor is documented in this view.
			var panorama := _make([], Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO)
			panorama["panorama"] = true
			return panorama
		# Grass and approach strips below the platform; no climbing the shrine steps.
		return _make([Vector2(120, 630), Vector2(1160, 630), Vector2(1190, 720), Vector2(90, 720)], Vector2(640, 675), Vector2(390, 675), Vector2(910, 675), Vector2(640, 685))
	if id == "angkor_pre_rup":
		if view_index == 1:
			# Steep stairs, ruined masonry and the stone basin are observation only.
			var panorama := _make([], Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO)
			panorama["panorama"] = true
			return panorama
		# Grass foreground only, below the terrace wall and clear of tree roots.
		return _make([Vector2(300, 625), Vector2(1160, 625), Vector2(1190, 708), Vector2(280, 708)], Vector2(680, 670), Vector2(440, 665), Vector2(960, 665), Vector2(680, 680))
	if id == "angkor_east_mebon":
		if view_index == 1:
			# Statue and terrace walls are observed from outside, never climbed.
			var panorama := _make([], Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO)
			panorama["panorama"] = true
			return panorama
		# The right-hand earth path stays clear of the raised foreground foundations.
		return _make([Vector2(1150, 510), Vector2(1240, 510), Vector2(1240, 708), Vector2(1030, 708)], Vector2(1170, 645), Vector2(1180, 570), Vector2(1120, 665), Vector2(1180, 680))
	if id == "angkor_ta_som":
		if view_index == 1:
			# Exposed roots, gate masonry and conservation supports are observation only.
			var panorama := _make([], Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO)
			panorama["panorama"] = true
			return panorama
		# Keep the traveler in the foreground below the sanctuary steps and rubble.
		return _make([Vector2(350, 640), Vector2(900, 640), Vector2(880, 720), Vector2(300, 720)], Vector2(640, 680), Vector2(460, 680), Vector2(800, 680), Vector2(650, 680))
	if id == "angkor_neak_pean":
		if view_index == 1:
			# The sanctuary island and all foreground pools are observation only.
			var panorama := _make([], Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO)
			panorama["panorama"] = true
			return panorama
		# Stay inside the timber deck, clear of edge posts and reservoir water.
		return _make([Vector2(530, 520), Vector2(800, 520), Vector2(1000, 708), Vector2(280, 708)], Vector2(640, 650), Vector2(540, 620), Vector2(820, 655), Vector2(650, 680))
	if id == "angkor_preah_khan":
		if view_index == 1:
			# The green foreground is algae-covered water, not grass.
			var panorama := _make([], Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO)
			panorama["panorama"] = true
			return panorama
		return _make([Vector2(480, 585), Vector2(800, 585), Vector2(1120, 708), Vector2(150, 708)], Vector2(640, 650), Vector2(510, 635), Vector2(820, 665), Vector2(650, 680))
	if id == "angkor_banteay_kdei":
		# Only the clear foreground earth is walkable; gateways and rubble stay outside.
		if view_index == 1:
			return _make([Vector2(140, 630), Vector2(1140, 630), Vector2(1180, 708), Vector2(100, 708)], Vector2(680, 675), Vector2(380, 670), Vector2(950, 670), Vector2(650, 680))
		return _make([Vector2(120, 625), Vector2(1140, 625), Vector2(1200, 708), Vector2(90, 708)], Vector2(640, 670), Vector2(350, 655), Vector2(930, 655), Vector2(640, 680))
	if id == "angkor_bakheng":
		# Both approved images are observation views, not surveyed walking areas.
		var panorama := _make([], Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO)
		panorama["panorama"] = true
		return panorama
	if id == "angkor_ta_prohm":
		match view_index:
			1: # The low-angle view leaves no safe walking space outside the ropes.
				var panorama := _make([], Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO)
				panorama["panorama"] = true
				return panorama
			2: # Boardwalk; keep roots, the fenced platform and ruins outside.
				return _make([Vector2(120, 540), Vector2(270, 540), Vector2(500, 685), Vector2(120, 685)], Vector2(280, 635), Vector2(190, 600), Vector2(320, 635), Vector2(260, 650))
			3: # Courtyard in front of the colonnade, right of the foreground tree.
				return _make([Vector2(390, 620), Vector2(1150, 620), Vector2(1150, 708), Vector2(390, 708)], Vector2(760, 665), Vector2(530, 665), Vector2(1010, 665), Vector2(760, 680))
		return _make([Vector2(100, 610), Vector2(490, 610), Vector2(490, 708), Vector2(100, 708)], Vector2(300, 660), Vector2(180, 660), Vector2(410, 660), Vector2(300, 680))
	if id == "angkor_wat":
		match view_index:
			1: # Reflection panorama has no walkable foreground: it is all water.
				var panorama := _make([], Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO)
				panorama["panorama"] = true
				return panorama
			2:
				return _make([Vector2(150, 620), Vector2(1130, 620), Vector2(1130, 708), Vector2(150, 708)], Vector2(640, 665), Vector2(410, 665), Vector2(930, 665), Vector2(650, 680))
			3:
				return _make([Vector2(380, 520), Vector2(680, 520), Vector2(990, 708), Vector2(230, 708)], Vector2(600, 635), Vector2(430, 620), Vector2(790, 680), Vector2(610, 680))
		return _make([Vector2(530, 540), Vector2(730, 540), Vector2(1010, 708), Vector2(240, 708)], Vector2(630, 645), Vector2(490, 625), Vector2(820, 675), Vector2(640, 680))
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
