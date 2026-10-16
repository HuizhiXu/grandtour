extends SceneTree

const MAIN := preload("res://scenes/main.tscn")
const Catalog := preload("res://scripts/game/tour_catalog.gd")
const Progress := preload("res://scripts/game/tour_progress.gd")
var _main: Node
var _ui: ExplorationUI
var _traveler: Traveler
var _checks := 0
var _failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var store := root.get_node("SaveStore")
	var original_tour: Dictionary = store.get_tour_progress()
	var original_postcard: Dictionary = store.get_postcard_progress()
	var original_palace: Dictionary = store.get_palace_progress()
	store.set_tour_progress({})
	_main = MAIN.instantiate()
	root.add_child(_main)
	await process_frame
	await physics_frame
	_ui = _main.get("_ui")
	_traveler = _main.get("_traveler")
	_check(Catalog.ROUTES[0].stops.size() == 8 and Catalog.ROUTES[1].stops.size() == 4, "two routes contain eight and four stops")
	_check(Catalog.ROUTES.size() == 3 and Catalog.ROUTES[2].stops.size() == 11, "Angkor contains all eleven reviewed stops")
	var all_stops: Array[String] = []
	var font := load("res://assets/template/fonts/ui_regular.tres") as Font
	var missing := ""
	for id: String in Catalog.STOPS:
		for key: String in ["title", "info", "prompt"]:
			for character: String in str(Catalog.STOPS[id].get(key, "")):
				if character.unicode_at(0) >= 32 and not font.has_char(character.unicode_at(0)) and character not in missing: missing += character
		for text: String in Catalog.STOPS[id].get("choices", []) + Catalog.STOPS[id].get("replies", []):
			for character: String in text:
				if character.unicode_at(0) >= 32 and not font.has_char(character.unicode_at(0)) and character not in missing: missing += character
	_check(missing.is_empty(), "all tour copy has bundled glyphs; missing: " + missing)
	for route_index in range(Catalog.ROUTES.size()):
		_main.set("_route_index", route_index)
		_main.call("_show_routes")
		await _layout()
		_check(_ui.has_modal(), "route book opens")
		_check(Rect2(0, 0, 1280, 720).encloses((_ui.get("_modal_panel") as Control).get_global_rect()), "route book fits viewport")
		await _capture("route-%d" % (route_index + 1))
		for id: String in Catalog.ROUTES[route_index].stops:
			print("[tour-tests] stop: " + id)
			_check(id not in all_stops, "unique stop: " + id)
			all_stops.append(id)
			_main.set("_route_index", route_index)
			_main.call("_show_routes")
			await _layout()
			var button := _stop_button(_ui.get("_modal_actions"), str(Catalog.STOPS[id].title))
			_check(button != null, "route book has real button: " + id)
			if button == null: continue
			button.pressed.emit()
			await _scene(str(Catalog.STOPS[id].scene))
			_check(Catalog.stop_for_scene(str(_main.get("_scene_id"))) == id, "route button reaches scene: " + id)
			_check((_main.get("_pathfinder") as IsoPathfinder).is_world_walkable(_traveler.position), "walkable arrival: " + id)
			if not Catalog.is_new_stop(id):
				var legacy := "palace_door" if id == "palace" else "post_office_door"
				_check((_main.get("_targets") as Dictionary).has(legacy), "original scene keeps interactions: " + id)
				var expected := "cathedral" if id == "palace" else "book_street"
				(_ui.get("_next_button") as Button).pressed.emit()
				await _scene(expected)
				_check(_main.get("_scene_id") == expected, "original stop follows new route order: " + id)
				continue
			await _capture(id + "-scene")
			_check(not (_main.get("_pathfinder") as IsoPathfinder).is_world_walkable(Vector2(640, 240)), "building is not walkable: " + id)
			if id in ["angkor_bayon", "angkor_royal_palace"]:
				_check(not (_main.get("_pathfinder") as IsoPathfinder).is_world_walkable(Vector2(400, 660)), "pond water cannot be walked on: " + id)
			_main.call("_show_current_journey")
			_main.call("_on_postcard_choice", 0)
			_check(_progress().stage(id) == 0, "remote record cannot grant progress: " + id)
			_ui.close_modal()
			await _approach("tour_record")
			_check(_progress().stage(id) == 0, "stamp cannot bypass activity: " + id)
			_ui.close_modal()
			await _approach("tour_info")
			_check(_ui.has_modal() and _progress().state(id).read, "reading requires physical arrival: " + id)
			_ui.close_modal()
			await _approach("tour_activity")
			_check(_ui.has_modal() and _progress().state(id).choice == -1, "activity requires a choice: " + id)
			_main.call("_on_postcard_choice", -1)
			_check(_progress().state(id).choice == -1, "invalid activity choice is rejected: " + id)
			var choices := _ui.get("_modal_actions") as VBoxContainer
			var choice := (all_stops.size() - 1) % 3
			if choices.get_child_count() < 3:
				_check(false, "activity choices unavailable: " + id)
				_ui.close_modal()
				continue
			(choices.get_child(choice) as Button).pressed.emit()
			_check(_progress().stage(id) == 2, "chosen impression is recorded: " + id)
			await _layout()
			_check(Rect2(0, 0, 1280, 720).encloses((_ui.get("_modal_panel") as Control).get_global_rect()), "activity modal fits: " + id)
			_ui.close_modal()
			await _approach("tour_record")
			_check(_main.get("_postcard_context") == "tour_record", "stamp confirmation at record point: " + id)
			((_ui.get("_modal_actions") as VBoxContainer).get_child(0) as Button).pressed.emit()
			_check(_progress().stage(id) == 3, "stop fully completed: " + id)
			await _layout()
			await _capture(id + "-record")
			_ui.close_modal()
			var index: int = Catalog.ROUTES[route_index].stops.find(id)
			(_ui.get("_next_button") as Button).pressed.emit()
			if index + 1 < Catalog.ROUTES[route_index].stops.size():
				var next: String = Catalog.ROUTES[route_index].stops[index + 1]
				await _scene(str(Catalog.STOPS[next].scene))
				_check(Catalog.stop_for_scene(str(_main.get("_scene_id"))) == next, "next button follows route order: " + id)
			else:
				_check(_ui.has_modal(), "last stop opens route summary: " + id)
				_ui.close_modal()
	store.call("_load")
	var restored := Progress.new()
	restored.restore(store.get_tour_progress())
	for id: String in all_stops:
		if Catalog.is_new_stop(id): _check(restored.stage(id) == 3, "disk save restores completed stop: " + id)
	_check(store.get_postcard_progress() == original_postcard, "routes preserve postcard save")
	_check(store.get_palace_progress() == original_palace, "routes preserve palace save")
	var malformed := Progress.new()
	malformed.restore({"cathedral": {"read": true, "choice": 99, "recorded": true}, "book_street": 5, "unknown": {"recorded": true}})
	_check(malformed.stage("cathedral") == 1 and malformed.stage("book_street") == 0 and not malformed.serialize().has("unknown"), "invalid and unknown saved progress is sanitized")
	_main.queue_free()
	await process_frame
	store.set_tour_progress(original_tour)
	root.get_node("AudioDirector").release_streams()
	if _failures.is_empty(): print("[tour-tests] PASS: %d route, scene, movement, activity, font and persistence checks" % _checks)
	else:
		for failure in _failures: push_error(failure)
	quit(0 if _failures.is_empty() else 1)

func _progress() -> RefCounted:
	return _main.get("_tour")

func _stop_button(parent: Node, title: String) -> Button:
	for child in parent.get_children():
		if child is Button and title in child.text: return child
		var found := _stop_button(child, title)
		if found != null: return found
	return null

func _approach(id: String) -> void:
	await physics_frame
	var target := (_main.get("_targets") as Dictionary)[id] as ExplorationTarget
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	target.call("_on_input_event", root, click, 0)
	for frame in range(900):
		await physics_frame
		if not _traveler.is_walking(): break
	_check(_traveler.position.distance_to(target.stand_position) <= 26, "actual arrival at " + str(_main.get("_scene_id")) + ": " + id)
	if _traveler.position.distance_to(target.stand_position) > 26:
		print("[tour-tests] unreachable: ", _main.get("_scene_id"), " ", id, " from ", _traveler.position, " to ", target.stand_position, " modal ", _ui.has_modal())
	await process_frame

func _scene(id: String) -> void:
	for frame in range(600):
		await physics_frame
		if _main.get("_scene_id") == id and not _main.get("_transitioning"): return
	_check(false, "transition timed out: " + id)

func _layout() -> void:
	await process_frame
	await process_frame
	await process_frame

func _capture(label: String) -> void:
	var directory := OS.get_environment("GRANDTOUR_CAPTURE_DIR")
	if directory.is_empty() or DisplayServer.get_name() == "headless": return
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(directory)
	root.get_texture().get_image().save_png(directory.path_join(label + ".png"))

func _check(condition: bool, label: String) -> void:
	_checks += 1
	if not condition: _failures.append(label)
