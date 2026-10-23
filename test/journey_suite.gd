extends SceneTree

const MAIN := preload("res://scenes/main.tscn")
const Catalog := preload("res://scripts/game/tour_catalog.gd")
const World := preload("res://scripts/game/tour_world.gd")
const HEXI_NAMES := [
	["中山桥", "正宁路夜市", "甘肃省博物馆"],
	["乌鞘岭", "天梯山石窟", "白塔寺", "南城门楼", "鸠摩罗什寺", "西夏博物馆", "武威文庙", "大云寺古钟楼", "武威市博物馆", "海藏寺"],
	["马蹄寺", "金塔寺", "镇远楼", "平山湖大峡谷", "七彩丹霞", "大佛寺"],
	["嘉峪关", "长城第一墩", "悬壁长城"],
	["莫高窟", "鸣沙山月牙泉", "敦煌夜市", "西千佛洞", "阳关", "玉门关", "雅丹魔鬼城"],
]
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
	store.get("_data")["travel_bookmarks"] = {"datong": "datong_hengshan", "angkor": "angkor_bayon", "hexi": "hexi_leitai"}
	_main = MAIN.instantiate()
	root.add_child(_main)
	await _layout()
	_ui = _main.get("_ui")
	_check(_ui.has_modal(), "startup opens the travel library")
	_check((_main.get("_journey_bookmarks") as Dictionary).get("datong", "") == "", "removed stop bookmark ignored")
	_check((_main.get("_journey_bookmarks") as Dictionary).get("hexi", "") == "", "retired Hexi stop bookmark ignored")
	_check((_main.get("_journey_bookmarks") as Dictionary).get("angkor") == "angkor_bayon", "valid bookmark restored")
	var shelf := _ui.find_child("JourneyShelf", true, false)
	_check(shelf != null and shelf.get_child_count() == 4, "four separate journey covers")
	_check(_on_screen(_ui.get("_modal_panel")), "travel library fits viewport")
	var owned := {}
	for journey: Dictionary in Catalog.JOURNEYS:
		var card := _ui.find_child("Journey_" + str(journey.id), true, false) as Button
		_check(card != null and _on_screen(card), "cover visible: " + str(journey.id))
		_check((card.find_child("Cover", true, false) as TextureRect).texture != null, "cover image loads: " + str(journey.id))
		_check(card.get_global_rect().encloses((card.find_child("Bookmark", true, false) as Control).get_global_rect()), "bookmark stays inside journey cover: " + str(journey.id))
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
	# Hexi's city tabs form one continuous journey, with a bookmark in each book.
	_ui.close_modal()
	_main.call("_select_journey", "hexi")
	await _layout()
	_check("河西走廊" in (_ui.get("_modal_title") as Label).text, "Hexi cover opens its own city routes")
	_check(Catalog.Hexi.STOPS.size() == 29, "Hexi includes the user's 29 stops")
	_check(Catalog.journey("hexi").start == "hexi_zhongshan_bridge", "Hexi starts at the user's first stop")
	_check(_find_button(_ui.get("_modal_actions"), "继续旅程 · 中山桥") != null, "retired bookmark falls back to Zhongshan Bridge")
	for retired_id: String in ["hexi_baita_mountain", "hexi_yellow_river_mother", "hexi_leitai"]:
		_check(not Catalog.STOPS.has(retired_id), "unlisted stop excluded: " + retired_id)
	for city in range(HEXI_NAMES.size()):
		var names: Array = []
		for id: String in Catalog.Hexi.ROUTES[city].stops:
			names.append(Catalog.STOPS[id].title)
		_check(names == HEXI_NAMES[city], "city matches requested names and order: %d" % city)
	for route_index: int in Catalog.journey("hexi").routes:
		var city_tab := _ui.find_child("JourneyRoute_%d" % route_index, true, false) as Button
		_check(city_tab != null and _on_screen(city_tab), "city tab fits viewport: " + str(route_index))
		if city_tab != null:
			city_tab.pressed.emit()
			await _layout()
			_check(_main.get("_route_index") == route_index, "city tab selects its own route")
			_check(_on_screen(_ui.get("_modal_panel")), "city route panel fits viewport: %d" % route_index)
			if route_index == 5:
				var scroll := _ui.find_child("RouteStops", true, false) as ScrollContainer
				var last := _find_button(scroll, "海藏寺")
				_check(last != null, "Wuwei includes its tenth stop")
				if last != null:
					scroll.ensure_control_visible(last)
					await _layout()
					_check(scroll.scroll_vertical > 0, "Wuwei list scrolls to the tenth stop")
					_check(scroll.get_global_rect().encloses(last.get_global_rect()), "Wuwei last stop is fully visible after scrolling")
	_check(_on_screen(_ui.get("_modal_panel")), "five-city route fits viewport")
	_ui.close_modal()
	for boundary: Array in [["hexi_gansu_museum", "hexi_wushaoling"], ["hexi_haizang_temple", "hexi_mati_temple"], ["hexi_zhangye_dafo", "hexi_jiayuguan_fortress"], ["hexi_overhanging_wall", "hexi_mogao"]]:
		_main.call("_travel_to_stop", str(boundary[0]))
		await _settle()
		_check(_main.call("_next_stop_id") == boundary[1], "next stop continues across city boundary: " + str(boundary[0]))
		(_ui.get("_next_button") as Button).pressed.emit()
		await _settle()
		_check(_main.get("_scene_id") == boundary[1], "next button reaches next city: " + str(boundary[1]))
		_check("乘车转场" in (_ui.get("_feedback_label") as Label).text, "cross-city transfer is labelled")
	_main.call("_travel_to_stop", "hexi_yadan")
	await _settle()
	_check(_main.call("_next_stop_id") == "", "Dunhuang ends the five-city journey")
	(_ui.get("_next_button") as Button).pressed.emit()
	await _layout()
	_check("河西走廊" in (_ui.get("_modal_title") as Label).text, "last Hexi stop returns to own book")
	_ui.close_modal()
	_main.call("_select_journey", "hexi")
	await _layout()
	_check(_find_button(_ui.get("_modal_actions"), "继续旅程 · 雅丹魔鬼城") != null, "Hexi resume point survives city navigation")
	_check((_main.get("_journey_bookmarks") as Dictionary).get("angkor") == "angkor_bayon", "Hexi travel preserves Angkor bookmark")
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
