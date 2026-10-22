extends SceneTree

const MAIN := preload("res://scenes/main.tscn")
const Catalog := preload("res://scripts/game/tour_catalog.gd")
const World := preload("res://scripts/game/tour_world.gd")
var _checks := 0
var _failures: Array[String] = []
var _main: Node
var _ui: ExplorationUI

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var store := root.get_node("SaveStore")
	var original: Dictionary = store.get("_data").duplicate(true)
	# Existing saves may still point to the removed Hengshan stop.
	store.get("_data")["travel_bookmarks"] = {"datong": "datong_hengshan", "angkor": "angkor_bayon"}
	_main = MAIN.instantiate()
	root.add_child(_main)
	await _layout()
	_ui = _main.get("_ui")
	_check(_ui.has_modal(), "startup opens the travel library")
	_check((_main.get("_journey_bookmarks") as Dictionary).get("datong", "") == "", "removed stop bookmark ignored")
	_check((_main.get("_journey_bookmarks") as Dictionary).get("angkor") == "angkor_bayon", "valid bookmark restored")
	var shelf := _ui.find_child("JourneyShelf", true, false)
	_check(shelf != null and shelf.get_child_count() == 3, "three separate journey covers")
	_check(_on_screen(_ui.get("_modal_panel")), "travel library fits viewport")
	var owned := {}
	for journey: Dictionary in Catalog.JOURNEYS:
		var card := _ui.find_child("Journey_" + str(journey.id), true, false) as Button
		_check(card != null and _on_screen(card), "cover visible: " + str(journey.id))
		_check((card.find_child("Cover", true, false) as TextureRect).texture != null, "cover image loads: " + str(journey.id))
		for route_index: int in journey.routes:
			for id: String in Catalog.ROUTES[route_index].stops:
				_check(not owned.has(id), "stop has one owner: " + id)
				owned[id] = journey.id
				_check(Catalog.journey_for_stop(id).id == journey.id, "correct journey: " + id)
	_check(owned.size() == Catalog.STOPS.size(), "every stop belongs to a journey")
	(_ui.find_child("Journey_datong", true, false) as Button).pressed.emit()
	await _layout()
	_check("大同及周边" in (_ui.get("_modal_title") as Label).text, "Datong cover opens its route")
	_check(_on_screen(_ui.get("_modal_panel")), "Datong route fits viewport")
	_check(_find_button(_ui.get("_modal_actions"), "悬空寺") != null, "Hanging Temple included")
	_check(_find_button(_ui.get("_modal_actions"), "应县木塔") != null, "Yingxian Pagoda included")
	_check(_find_button(_ui.get("_modal_actions"), "中央邮局") == null, "other journeys do not crowd Datong route")
	_main.call("_setup_scene", "pink_church", Vector2(640, 620))
	(_find_button(_ui.get("_modal_actions"), "悬空寺") as Button).pressed.emit()
	await _settle()
	_check(_main.get("_scene_id") == "datong_hanging_temple", "route button reaches Hanging Temple")
	_check(_main.get("_panorama") and not (_main.get("_traveler") as Node2D).visible, "cliff scene is observation only")
	_check("浑源" in (_ui.get("_location_label") as Label).text, "Hunyuan location label")
	_check("翻开新旅程" in (_ui.get("_feedback_label") as Label).text, "cross-country travel does not inherit a city car transfer")
	_check(_main.call("_next_stop_id") == "yingxian_wooden_pagoda", "next stop remains inside Datong journey")
	(_ui.get("_next_button") as Button).pressed.emit()
	await _settle()
	_check(_main.get("_scene_id") == "yingxian_wooden_pagoda", "next button reaches Yingxian Pagoda")
	_check("朔州应县" in (_ui.get("_location_label") as Label).text, "Yingxian correctly labelled outside Datong")
	_check(_main.call("_next_stop_id") == "", "journey ends without jumping countries")
	(_ui.get("_next_button") as Button).pressed.emit()
	await _layout()
	_check(_ui.has_modal() and "大同及周边" in (_ui.get("_modal_title") as Label).text, "last stop returns to own route")
	_ui.close_modal()
	_main.call("_return_to_start")
	await _settle()
	_check(_main.get("_scene_id") == "datong_city_wall", "restart returns to this journey's beginning")
	for id: String in Catalog.Datong.STOPS:
		_main.call("_travel_to_stop", id)
		await _settle()
		_check(_main.get("_scene_id") == id, "Datong scene loads: " + id)
		var background := _main.get_node("PaintedWorld/SceneIllustration") as Sprite2D
		_check(background.texture != null, "painting loads: " + id)
		(_ui.get("_quest_button") as Button).pressed.emit()
		await _layout()
		_check(_ui.has_modal(), "introduction opens: " + id)
		_check((_ui.get("_modal_body") as Label).text == Catalog.STOPS[id].info, "correct introduction: " + id)
		_check(_on_screen(_ui.get("_modal_panel")), "introduction fits viewport: " + id)
		_ui.close_modal()
		if not World.layout(id).panorama:
			var traveler := _main.get("_traveler") as Traveler
			var pathfinder := _main.get("_pathfinder") as IsoPathfinder
			var origin := traveler.global_position
			_check(not (_ui.get("_hint_panel") as Control).get_global_rect().has_point(origin), "spawn clear of bottom hint panel: " + id)
			_check(pathfinder.is_world_walkable(origin), "spawn lies on clear paving: " + id)
			# An unsafe click on a monument must resolve to the public foreground.
			var route := pathfinder.find_path(origin, Vector2(640, 300))
			_check(not route.is_empty(), "unsafe click resolves to paving: " + id)
			for point: Vector2 in route:
				_check(Geometry2D.is_point_in_polygon(point, World.layout(id).floor), "route cannot enter monument or pool: " + id)
			_main.call("_request_walk", Vector2(250, 685))
			for frame in range(12): await physics_frame
			_check(traveler.global_position.distance_to(origin) > 1.0, "character actually walks: " + id)
			_check(Geometry2D.is_point_in_polygon(traveler.global_position, World.layout(id).floor), "character stays on paving: " + id)
	_check(store.get_travel_bookmarks().get("datong") == "yingxian_wooden_pagoda", "latest Datong stop persisted")
	store.call("_load")
	_check(store.get_travel_bookmarks().get("datong") == "yingxian_wooden_pagoda", "Datong bookmark survives disk reload")
	_check(store.get_travel_bookmarks().get("angkor") == "angkor_bayon", "disk reload preserves other journeys")
	_main.call("_show_journeys")
	await _layout()
	(_ui.find_child("Journey_angkor", true, false) as Button).pressed.emit()
	await _layout()
	var resume := _find_button(_ui.get("_modal_actions"), "继续旅程 · 巴戎寺")
	_check(resume != null, "each journey keeps its own resume point")
	if resume != null:
		resume.pressed.emit()
		await _settle()
		_check(_main.get("_scene_id") == "angkor_bayon", "resume returns to saved Angkor stop")
	store.set("_data", original)
	store.save()
	_main.queue_free()
	await process_frame
	for failure: String in _failures: push_error(failure)
	if _failures.is_empty(): print("[journey-tests] PASS: %d library, route, Datong, navigation and bookmark checks" % _checks)
	quit(0 if _failures.is_empty() else 1)

func _settle() -> void:
	for frame in range(180):
		await process_frame
		if not _main.get("_transitioning"): return
	_check(false, "scene transition completes")

func _layout() -> void:
	await process_frame
	await process_frame
	await process_frame

func _on_screen(control: Control) -> bool:
	return control != null and Rect2(0, 0, 1280, 720).encloses(control.get_global_rect())

func _find_button(parent: Node, text: String) -> Button:
	for child in parent.get_children():
		if child is Button and text in child.text: return child
		var found := _find_button(child, text)
		if found != null: return found
	return null

func _check(condition: bool, label: String) -> void:
	_checks += 1
	if not condition: _failures.append(label)
