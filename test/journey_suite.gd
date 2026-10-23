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
const TURKEY_NAMES := [
	["博斯普鲁斯海峡", "圣索菲亚大教堂", "老皇宫", "蓝色清真寺", "君士坦丁堡竞技场遗址", "锡尔凯吉火车站", "纯真博物馆", "独立大街", "加拉太塔", "如梅利堡垒"],
	["安纳托利亚高原", "格雷梅", "内夫谢希尔", "凯马克利", "鸽子谷", "乌奇萨尔", "格雷梅露天博物馆", "阿瓦诺斯", "红谷"],
	["塞尔丘克（Selçuk）", "以弗所古城（Ephesus）", "切什梅（Çeşme）", "阿拉恰特（Alaçatı）", "大电梯", "市中心钟楼"],
	["安塔利亚机场", "西代 / Side", "阿波罗神庙", "阿斯潘多斯古剧场（Aspendos）", "佩尔格古城（Perge）"],
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
	store.get("_data")["last_travel_stop"] = "retired_stop"
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
	_check(shelf != null and shelf.get_child_count() == 5, "five separate journey covers")
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
					_check(scroll.get_global_rect().encloses(last.get_global_rect()), "Wuwei tenth stop is fully accessible in compact list")
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
	_ui.close_modal()
	(_main.get("_journey_bookmarks") as Dictionary)["turkey"] = "turkey_alacati"
	_main.call("_select_journey", "turkey")
	await _layout()
	_check(Catalog.Turkey.STOPS.size() == 30, "Turkey includes all requested 30 stops")
	_check(Catalog.journey("turkey").start == "turkey_bosphorus", "Turkey starts at the Bosphorus")
	_check("土耳其" in (_ui.get("_modal_title") as Label).text, "Turkey cover opens its own book")
	_check(_find_button(_ui.get("_modal_actions"), "继续旅程 · 阿拉恰特（Alaçatı）") != null, "Turkey restores its own bookmark")
	for region_index in range(TURKEY_NAMES.size()):
		var names: Array = []
		for id: String in Catalog.Turkey.ROUTES[region_index].stops:
			names.append(Catalog.STOPS[id].title)
		_check(names == TURKEY_NAMES[region_index], "Turkey region matches names and order: %d" % region_index)
		var route_index: int = Catalog.journey("turkey").routes[region_index]
		var region_tab := _ui.find_child("JourneyRoute_%d" % route_index, true, false) as Button
		_check(region_tab != null and _on_screen(region_tab), "Turkey region tab visible: %d" % region_index)
		if region_tab != null:
			region_tab.pressed.emit()
			await _layout()
			_check(_main.get("_route_index") == route_index, "Turkey region tab selects correct region")
			_check(_on_screen(_ui.get("_modal_panel")), "Turkey region route fits viewport")
			var scroll := _ui.find_child("RouteStops", true, false) as ScrollContainer
			var last_title: String = TURKEY_NAMES[region_index].back()
			var last := _find_button(scroll, last_title)
			_check(last != null, "Turkey region includes its last stop")
			if last != null:
				scroll.ensure_control_visible(last)
				await _layout()
				_check(scroll.get_global_rect().encloses(last.get_global_rect()), "Turkey last stop fully accessible")
	_ui.close_modal()
	for boundary: Array in [["turkey_rumeli", "turkey_anatolian_plateau"], ["turkey_red_valley", "turkey_selcuk"], ["turkey_clock_tower", "turkey_antalya_airport"]]:
		_main.call("_travel_to_stop", str(boundary[0]))
		await _settle()
		_check(_main.call("_next_stop_id") == boundary[1], "Turkey next stop crosses region boundary")
		(_ui.get("_next_button") as Button).pressed.emit()
		await _settle()
		_check(_main.get("_scene_id") == boundary[1], "Turkey next button reaches following region")
		_check("翻页转场" in (_ui.get("_feedback_label") as Label).text, "Turkey distant travel uses page transition")
	_main.call("_travel_to_stop", "turkey_perge")
	await _settle()
	_check(_main.call("_next_stop_id") == "", "Perge ends Turkey without crossing to another country")
	(_ui.get("_next_button") as Button).pressed.emit()
	await _layout()
	_check(_ui.has_modal() and "土耳其" in (_ui.get("_modal_title") as Label).text, "Turkey last stop returns to its own route")
	_ui.close_modal()
	_check(store.get_travel_bookmarks().get("turkey") == "turkey_perge", "Turkey latest stop persisted")
	store.call("_load")
	_check(store.get_travel_bookmarks().get("turkey") == "turkey_perge", "Turkey bookmark survives disk reload")
	_check(store.get_travel_bookmarks().get("hexi") == "hexi_yadan", "Turkey preserves Hexi bookmark")
	_check(store.get_travel_bookmarks().get("angkor") == "angkor_bayon", "Turkey preserves Angkor bookmark")
	_main.call("_return_to_start")
	await _settle()
	_check(_main.get("_scene_id") == "turkey_bosphorus", "Turkey restart returns to its own beginning")
	var walking_count := 0
	for id: String in Catalog.Turkey.STOPS:
		var ground: Dictionary = World.layout(id)
		if ground.panorama: continue
		walking_count += 1
		_main.call("_travel_to_stop", id)
		await _settle()
		var traveler := _main.get("_traveler") as Traveler
		var pathfinder := _main.get("_pathfinder") as IsoPathfinder
		var origin := traveler.global_position
		_check(traveler.visible, "Turkey walking actor visible: " + id)
		_check(pathfinder.is_world_walkable(origin), "Turkey spawn is on reachable ground: " + id)
		_check(not (_ui.get("_hint_panel") as Control).get_global_rect().has_point(origin), "Turkey spawn clear of hint panel: " + id)
		var route := pathfinder.find_path(origin, Vector2(640, 260))
		_check(not route.is_empty(), "Turkey monument click resolves to safe ground: " + id)
		for point: Vector2 in route:
			_check(Geometry2D.is_point_in_polygon(point, ground.floor), "Turkey route stays on ground: " + id)
		var destination: Vector2 = ground.floor[0].lerp(ground.floor[1], 0.5).lerp(origin, 0.25)
		_main.call("_request_walk", destination)
		for frame in range(20): await physics_frame
		_check(traveler.global_position.distance_to(origin) > 1.0, "Turkey actor actually walks: " + id)
		_check(Geometry2D.is_point_in_polygon(traveler.global_position, ground.floor), "Turkey actor stays in the calibrated ground: " + id)
	_check(walking_count == 7, "Turkey has seven calibrated walking scenes")
	await _check_navigation_polish(store)
	store.set("_data", original)
	store.save()
	_main.queue_free()
	await process_frame
	for failure: String in _failures: push_error(failure)
	if _failures.is_empty(): print("[journey-tests] PASS: %d library, route, Datong, navigation and bookmark checks" % _checks)
	quit(0 if _failures.is_empty() else 1)

func _check_navigation_polish(store: Node) -> void:
	_main.call("_travel_to_stop", "turkey_hagia_sophia")
	await _settle()
	_check("博斯普鲁斯海峡" in (_ui.get("_previous_button") as Button).text, "previous button names destination")
	_check("老皇宫" in (_ui.get("_next_button") as Button).text, "next button names destination")
	_check("2 / 30" in (_ui.get("_journey_label") as Label).text, "current position is shown within own book")
	_check(not (_ui.get("_quest_panel") as Control).visible, "introduction does not duplicate location panel")
	_check((_ui.get("_quest_button") as Button).is_visible_in_tree(), "compact panel retains introduction action")
	for key: String in ["_identity", "_previous_button", "_next_button", "_route_button", "_library_button", "_scenery_button"]:
		_check(_on_screen(_ui.get(key)), "navigation fits viewport: " + key)
	# A previously browsed book must not change where the direct directory opens.
	_main.set("_route_index", 2)
	(_ui.get("_route_button") as Button).pressed.emit()
	await _layout()
	_check(_main.get("_route_index") == 9 and "土耳其" in (_ui.get("_modal_title") as Label).text, "direct directory opens current book and region")
	var scroll := _ui.find_child("RouteStops", true, false) as ScrollContainer
	var last := _ui.find_child("Stop_turkey_rumeli", true, false) as Button
	_check(scroll.get_global_rect().encloses(last.get_global_rect()), "all ten Istanbul entries fit without scrolling")
	_check((_ui.find_child("Stop_turkey_hagia_sophia", true, false) as Button).text.ends_with("观景"), "panorama entry labelled before entering")
	_check((_ui.find_child("Stop_turkey_istiklal", true, false) as Button).text.ends_with("可漫步"), "walking entry labelled before entering")
	for route_index in [9, 10, 2]:
		_main.set("_route_index", route_index)
		_main.call("_show_routes")
		await _layout()
		(_ui.find_child("RouteDetailsToggle", true, false) as Button).pressed.emit()
		await _layout()
		_check((_ui.find_child("RouteDetails", true, false) as Control).visible, "route explanation expands: " + str(route_index))
		_check(_on_screen(_ui.get("_modal_panel")), "expanded explanation stays within viewport: " + str(route_index))
		(_ui.find_child("RouteDetailsToggle", true, false) as Button).pressed.emit()
		await _layout()
		_check(not (_ui.find_child("RouteDetails", true, false) as Control).visible, "route explanation collapses: " + str(route_index))
	_ui.close_modal()
	var hide_key := InputEventKey.new()
	hide_key.keycode = KEY_H
	hide_key.pressed = true
	_main.call("_unhandled_input", hide_key)
	_check(_ui.is_scenery_only() and not (_ui.get("_hud_root") as Control).visible, "H hides browsing interface")
	_check((_ui.get("_scenery_button") as Button).is_visible_in_tree(), "scenery mode keeps a visible restore button")
	var escape := InputEventAction.new()
	escape.action = "pause"
	escape.pressed = true
	_main.call("_unhandled_input", escape)
	_check(not _ui.is_scenery_only() and not _main.get("_paused"), "Escape first restores interface without pausing")
	(_ui.get("_scenery_button") as Button).pressed.emit()
	_main.call("_set_paused", true)
	_check(not _ui.is_scenery_only() and (_ui.get("_pause_panel") as Control).visible, "pause restores hidden interface")
	_main.call("_set_paused", false)
	_main.call("_travel_to_stop", "turkey_anatolian_plateau")
	await _settle()
	(_ui.get("_previous_button") as Button).pressed.emit()
	await _settle()
	_check(_main.get("_scene_id") == "turkey_rumeli", "previous button crosses Turkey region boundary backwards")
	(_ui.get("_next_button") as Button).pressed.emit()
	await _settle()
	_check(_main.get("_scene_id") == "turkey_anatolian_plateau", "forward and backward boundary navigation are reciprocal")
	_main.call("_travel_to_stop", "turkey_bosphorus")
	await _settle()
	_check((_ui.get("_previous_button") as Button).disabled, "book start disables previous instead of jumping countries")
	_check(Catalog.neighbor_stop("turkey_perge", 1).is_empty(), "book end stays inside Turkey")
	_main.call("_travel_to_stop", "turkey_hagia_sophia")
	await _settle()
	_main.call("_travel_to_stop", "angkor_bayon")
	await _settle()
	_main.call("_travel_to_stop", "turkey_hagia_sophia")
	await _settle()
	store.call("_load")
	_check(store.call("get_last_travel_stop") == "turkey_hagia_sophia", "revisiting an existing book bookmark updates global resume on disk")
	_check(store.call("get_travel_bookmarks").get("angkor") == "angkor_bayon", "global resume preserves independent book bookmarks")
	_main.queue_free()
	await _layout()
	_main = MAIN.instantiate()
	root.add_child(_main)
	await _layout()
	_ui = _main.get("_ui")
	_check(_main.get("_scene_id") == "turkey_hagia_sophia", "restart prepares most recently visited destination")
	_check(_ui.has_modal() and _find_button(_ui.get("_modal_actions"), "继续旅程 · 圣索菲亚大教堂") != null, "startup library resumes last real destination")
	(_find_button(_ui.get("_modal_actions"), "继续旅程 · 圣索菲亚大教堂") as Button).pressed.emit()
	_check(not _ui.has_modal() and _main.get("_scene_id") == "turkey_hagia_sophia", "one click continues last trip")

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
