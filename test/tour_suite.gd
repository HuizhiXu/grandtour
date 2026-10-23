extends SceneTree

const MAIN := preload("res://scenes/main.tscn")
const Catalog := preload("res://scripts/game/tour_catalog.gd")
const World := preload("res://scripts/game/tour_world.gd")
var _main: Node
var _ui: ExplorationUI
var _checks := 0
var _failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var store := root.get_node("SaveStore")
	var old_tour: Dictionary = store.get_tour_progress().duplicate(true)
	var old_palace: Dictionary = store.get_palace_progress().duplicate(true)
	var old_postcard: Dictionary = store.get_postcard_progress().duplicate(true)
	var old_bookmarks: Dictionary = store.get_travel_bookmarks()
	var old_last_stop: String = store.get_last_travel_stop()
	var legacy_tour := {"cathedral": {"read": true, "choice": 2, "recorded": true}, "angkor_wat": {"read": true, "choice": 0, "recorded": false}}
	var legacy_palace := {"architecture": true, "garden": true, "exhibit": true, "souvenir": true}
	store.set_tour_progress(legacy_tour)
	store.set_palace_progress(legacy_palace)
	var legacy := preload("res://scripts/game/tour_progress.gd").new()
	legacy.restore(legacy_tour)
	_check(legacy.serialize() == legacy_tour, "retired activity data remains readable")
	_main = MAIN.instantiate()
	root.add_child(_main)
	await process_frame
	await physics_frame
	_ui = _main.get("_ui")
	_ui.close_modal()
	_check(Catalog.STOPS.size() == 104, "74 existing and 30 Turkey destinations remain available")
	for route_index in range(Catalog.ROUTES.size()):
		for id: String in Catalog.ROUTES[route_index].stops:
			_main.set("_route_index", route_index)
			_main.call("_show_routes")
			await _layout()
			_check(Rect2(0, 0, 1280, 720).encloses((_ui.get("_modal_panel") as Control).get_global_rect()), "route fits viewport: " + id)
			var button := _stop_button(_ui.find_child("RouteStops", true, false), Catalog.STOPS[id].title)
			_check(button != null, "route button exists: " + id)
			if button == null: continue
			button.pressed.emit()
			await _settle()
			_check(Catalog.stop_for_scene(_main.get("_scene_id")) == id, "route reaches destination: " + id)
			if id == "post_office":
				_check((_main.get("_targets") as Dictionary).has("post_office_door"), "post office keeps exploration")
				continue
			for key: String in ["activity", "object", "prompt", "choices", "replies"]:
				_check(not Catalog.STOPS[id].has(key), "removed activity data: " + id + "/" + key)
			await _check_introduction(id)
			for index in range(Catalog.views(id).size()):
				_main.call("_show_views")
				await _layout()
				var actions := _ui.get("_modal_actions") as VBoxContainer
				_check(actions.get_child_count() == Catalog.views(id).size() + 1, "view choices retained: " + id)
				var view_button := actions.get_child(index) as Button
				_check(view_button.icon != null, "view thumbnail loads: " + id)
				view_button.pressed.emit()
				await _settle()
				_check(_main.get("_view_index") == index, "view selection works: " + id)
				_check((_main.get("_traveler") as Node2D).visible != bool(_main.get("_panorama")), "scenic walking mode preserved: " + id)
				await _check_introduction(id)
	_check(store.get_tour_progress() == legacy_tour, "reading preserves old tour saves")
	_check(store.get_palace_progress() == legacy_palace, "reading preserves old palace saves")
	_check(store.get_postcard_progress() == old_postcard, "travel preserves postcard save")
	_check((_main.call("_completed_stops") as Dictionary).keys() == ["post_office"], "old exploration completion cannot reappear")
	store.set_tour_progress(old_tour)
	store.set_palace_progress(old_palace)
	store.get("_data")["travel_bookmarks"] = old_bookmarks
	store.get("_data")["last_travel_stop"] = old_last_stop
	store.save()
	_main.queue_free()
	await process_frame
	if _failures.is_empty():
		print("[tour-tests] PASS: %d route, view, introduction and save checks" % _checks)
	else:
		for failure: String in _failures: push_error(failure)
	quit(0 if _failures.is_empty() else 1)

func _check_introduction(id: String) -> void:
	_check((_main.get("_targets") as Dictionary).is_empty(), "no exploration props: " + id)
	_check(not (_ui.get("_exploration_button") as Button).visible, "no exploration guidance: " + id)
	var button := _ui.get("_quest_button") as Button
	_check(button.text == "景点介绍", "single introduction entry: " + id)
	_check(not "/" in (_ui.get("_quest_progress") as Label).text, "no task counter: " + id)
	_main.call("_set_paused", true)
	button.pressed.emit()
	_check(not _ui.has_modal(), "introduction respects pause: " + id)
	_main.call("_set_paused", false)
	button.pressed.emit()
	await _layout()
	_check(_ui.has_modal(), "introduction opens directly: " + id)
	_check((_ui.get("_modal_body") as Label).text == Catalog.STOPS[id].info, "correct introduction: " + id)
	_check((_ui.get("_modal_actions") as VBoxContainer).get_child_count() == 1, "introduction has only close action: " + id)
	_check(Rect2(0, 0, 1280, 720).encloses((_ui.get("_modal_panel") as Control).get_global_rect()), "introduction fits viewport: " + id)
	_ui.close_modal()
	if not bool(_main.get("_panorama")):
		var feet: Vector2 = (_main.get("_traveler") as Node2D).global_position
		var actor_rect := Rect2(feet - Vector2(30, 90), Vector2(60, 92))
		for key: String in ["_previous_button", "_next_button"]:
			_check(not (_ui.get(key) as Control).get_global_rect().intersects(actor_rect), "paging does not cover arriving actor: " + id + "/" + key)

func _settle() -> void:
	for frame in range(120):
		await process_frame
		if not _main.get("_transitioning"): return
	_check(false, "scene transition completes")

func _layout() -> void:
	await process_frame
	await process_frame
	await process_frame

func _stop_button(parent: Node, title: String) -> Button:
	for child in parent.get_children():
		if child is Button and title in child.text: return child
		var found := _stop_button(child, title)
		if found != null: return found
	return null

func _check(condition: bool, label: String) -> void:
	_checks += 1
	if not condition: _failures.append(label)
