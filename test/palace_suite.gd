extends SceneTree

const MAIN := preload("res://scenes/main.tscn")
const Visit := preload("res://scripts/game/palace_visit.gd")
var _failures: Array[String] = []
var _checks := 0
var _main: Node
var _ui: ExplorationUI
var _traveler: Traveler


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var store := root.get_node("SaveStore")
	var old_visit: Dictionary = store.get_palace_progress()
	var old_postcard: Dictionary = store.get_postcard_progress()
	store.set_palace_progress({})
	_main = MAIN.instantiate()
	root.add_child(_main)
	await process_frame
	await physics_frame
	_ui = _main.get("_ui")
	_traveler = _main.get("_traveler")
	# Test the actual composite fonts, including Vietnamese extended vowels.
	# The old common-Chinese coverage check alone cannot detect these holes.
	for resource: String in ["ui_regular", "ui_medium", "ui_bold"]:
		var font := load("res://assets/template/fonts/" + resource + ".tres") as Font
		for character: String in "Ngô Viết Thụ":
			_check(font.has_char(character.unicode_at(0)), resource + " covers architect name: " + character)
	await _approach("palace_travel")
	await _scene("palace_garden")
	_check(_main.get("_scene_id") == "palace_garden", "real travel target opens second stop")
	await _capture("01-palace-garden")
	_check(not _pathfinder().is_world_walkable(Vector2(645, 478)), "lawn and fountain cannot be walked through")
	_check(not _pathfinder().is_world_walkable(Vector2(640, 220)), "facade cannot be walked through")
	for id: String in ["palace_architecture", "palace_view", "palace_door", "post_office_return"]:
		var target := (_main.get("_targets") as Dictionary)[id] as ExplorationTarget
		var route := _pathfinder().find_path(_traveler.position, target.stand_position)
		_check(not route.is_empty() and route[-1].distance_to(target.stand_position) < 1.0, "exact reachable garden interaction: " + id)
		var anchor := _traveler.position
		for point in route:
			_check(_pathfinder()._line_is_clear(anchor, point), "route respects lawn and boundaries: " + id)
			anchor = point
	await _approach("palace_architecture")
	_check(_ui.has_modal() and _visit().architecture_read, "architecture advances only after approaching plaque")
	var body := _ui.get("_modal_body") as Label
	var body_font := body.get_theme_font("font")
	_check(body_font.has_char(0x1EBF) and body_font.has_char(0x1EE5), "rendered information body resolves Vietnamese glyphs")
	await _capture("01b-palace-architecture-font")
	_ui.close_modal()
	await _approach("palace_view")
	_check(_visit().stage() == 2, "garden viewpoint records second observation")
	_ui.close_modal()
	await _approach("palace_door")
	await _scene("palace_hall")
	_check(_main.get("_scene_id") == "palace_hall", "entrance reached on foot opens hall")
	_check(_pathfinder().is_world_walkable(_traveler.position), "hall spawn is walkable")
	await _capture("02-palace-hall")
	await _approach("palace_souvenir")
	_check(_visit().stage() == 2, "souvenir cannot skip unread exhibit")
	_ui.close_modal()
	await _approach("palace_exhibit")
	_check(_visit().stage() == 3, "exhibit unlocks souvenir")
	_ui.close_modal()
	_main.call("_show_current_journey")
	_check(_main.get("_postcard_context") == "palace_status", "remote HUD cannot collect souvenir")
	_ui.close_modal()
	await _approach("palace_souvenir")
	_check(_main.get("_postcard_context") == "palace_collect", "souvenir waits for confirmation at desk")
	_main.call("_on_postcard_choice", 0)
	_check(_visit().stage() == 4, "confirmed souvenir completes visit")
	await _capture("03-palace-souvenir")
	var restored := Visit.new()
	restored.restore(store.get_palace_progress())
	_check(restored.stage() == 4, "visit persists through save and restore")
	_check(store.get_postcard_progress() == old_postcard, "second stop preserves postcard progress")
	_ui.close_modal()
	await _approach("palace_exit")
	await _scene("palace_garden")
	_check(_pathfinder().is_world_walkable(_traveler.position), "garden return lands on reachable entrance paving")
	await _approach("post_office_return")
	await _scene("outdoor")
	_check(_main.get("_scene_id") == "outdoor", "return route reaches original post office")
	_check((_ui.get("_quest_title") as Label).text == "寄出西贡的第一张明信片", "return restores first stop HUD")
	await _capture("04-post-office-route")
	# A new game instance reads the same progress as a browser refresh.
	_main.queue_free()
	await process_frame
	_main = MAIN.instantiate()
	root.add_child(_main)
	await process_frame
	_check((_main.get("_palace")).stage() == 4, "new scene restores completed visit")
	_main.queue_free()
	await process_frame
	store.set_palace_progress(old_visit)
	root.get_node("AudioDirector").release_streams()
	if _failures.is_empty():
		print("[palace-tests] PASS: %d checks" % _checks)
	else:
		for failure in _failures:
			push_error(failure)
	quit(0 if _failures.is_empty() else 1)


func _visit() -> RefCounted:
	return _main.get("_palace")


func _pathfinder() -> IsoPathfinder:
	return _main.get("_pathfinder")


func _approach(id: String) -> void:
	await physics_frame
	var target := (_main.get("_targets") as Dictionary).get(id) as ExplorationTarget
	if target == null:
		_check(false, "missing target: " + id)
		return
	_main.call("_on_target_selected", target)
	for frame in range(1000):
		await physics_frame
		if not _traveler.is_walking():
			break
	_check(_traveler.position.distance_to(target.stand_position) <= 26.0, "traveler physically reaches " + id)
	await process_frame


func _scene(id: String) -> void:
	for frame in range(300):
		await process_frame
		if _main.get("_scene_id") == id and not _main.get("_transitioning"):
			return
	_check(false, "scene transition timeout: " + id)


func _capture(label: String) -> void:
	var directory := OS.get_environment("GRANDTOUR_CAPTURE_DIR")
	if directory.is_empty() or DisplayServer.get_name() == "headless":
		return
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(directory)
	root.get_texture().get_image().save_png(directory.path_join(label + ".png"))


func _check(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(label)
