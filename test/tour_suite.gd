extends SceneTree

const MAIN := preload("res://scenes/main.tscn")
const Catalog := preload("res://scripts/game/tour_catalog.gd")
const Progress := preload("res://scripts/game/tour_progress.gd")
const World := preload("res://scripts/game/tour_world.gd")
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
	_check(Catalog.ROUTES.size() == 3 and Catalog.ROUTES[2].stops.size() == 18, "Angkor contains all eighteen reviewed stops")
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
			var scroll := (_ui.get("_modal_actions") as Control).get_node("RouteStops") as ScrollContainer
			scroll.ensure_control_visible(button)
			await _layout()
			_check(scroll.get_global_rect().encloses(button.get_global_rect()), "route button scrolls fully into view: " + id)
			button.pressed.emit()
			await _scene(str(Catalog.STOPS[id].scene))
			_check(Catalog.stop_for_scene(str(_main.get("_scene_id"))) == id, "route button reaches scene: " + id)
			var observation_only: bool = Catalog.STOPS[id].get("observation_only", false)
			if not observation_only:
				_check((_main.get("_pathfinder") as IsoPathfinder).is_world_walkable(_traveler.position), "walkable arrival: " + id)
			_check((_ui.get("_exploration_button") as Button).visible == id.begins_with("angkor_"), "guided exploration only appears at unfinished Angkor stops: " + id)
			if not Catalog.is_new_stop(id):
				var legacy := "palace_door" if id == "palace" else "post_office_door"
				_check((_main.get("_targets") as Dictionary).has(legacy), "original scene keeps interactions: " + id)
				var expected := "cathedral" if id == "palace" else "book_street"
				(_ui.get("_next_button") as Button).pressed.emit()
				await _scene(expected)
				_check(_main.get("_scene_id") == expected, "original stop follows new route order: " + id)
				continue
			await _capture(id + "-scene")
			if observation_only:
				await _verify_observation_stop(id)
				await _verify_next_stop(id, route_index)
				continue
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
			await _approach("tour_info", id.begins_with("angkor_"))
			_check(_ui.has_modal() and _progress().state(id).read, "reading requires physical arrival: " + id)
			_ui.close_modal()
			if Catalog.views(id).size() == 4: await _verify_view_return(id)
			elif id in ["angkor_preah_khan", "angkor_neak_pean", "angkor_ta_som"]: await _verify_single_ground_return(id)
			elif not Catalog.views(id).is_empty(): await _verify_ground_view_return(id)
			await _approach("tour_activity", id.begins_with("angkor_"))
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
			await _approach("tour_record", id.begins_with("angkor_"))
			_check(_main.get("_postcard_context") == "tour_record", "stamp confirmation at record point: " + id)
			((_ui.get("_modal_actions") as VBoxContainer).get_child(0) as Button).pressed.emit()
			_check(_progress().stage(id) == 3, "stop fully completed: " + id)
			_check(not (_ui.get("_exploration_button") as Button).visible, "completed stops hide next-action guidance: " + id)
			await _layout()
			await _capture(id + "-record")
			_ui.close_modal()
			if not Catalog.views(id).is_empty(): await _verify_views(id)
			await _verify_next_stop(id, route_index)
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

func _verify_next_stop(id: String, route_index: int) -> void:
	var index: int = Catalog.ROUTES[route_index].stops.find(id)
	(_ui.get("_next_button") as Button).pressed.emit()
	if index + 1 < Catalog.ROUTES[route_index].stops.size():
		var next: String = Catalog.ROUTES[route_index].stops[index + 1]
		await _scene(str(Catalog.STOPS[next].scene))
		_check(Catalog.stop_for_scene(str(_main.get("_scene_id"))) == next, "next button follows route order: " + id)
	else:
		_check(_ui.has_modal(), "last stop opens route summary: " + id)
		_ui.close_modal()


func _verify_observation_stop(id: String) -> void:
	var button := _ui.get("_exploration_button") as Button
	_check(Catalog.views(id).size() == 2, "Bakheng has both approved observation views")
	_check(_progress().stage(id) == 0, "observation stop arrival grants no progress")
	_check(_main.get("_panorama") and not _traveler.visible and (_main.get("_targets") as Dictionary).is_empty(), "observation stop has no walking actor or targets")
	_check(not (_ui.get("_ground_button") as Button).visible, "observation stop has no nonexistent ground return")
	_check("景点介绍" in button.text and "走近" not in button.text, "observation stop offers explicit reading action")
	_main.call("_show_current_journey")
	button.pressed.emit()
	_main.call("_on_postcard_choice", 0)
	_check(_progress().stage(id) == 0, "open status modal cannot advance observation progress")
	_ui.close_modal()
	_main.call("_set_paused", true)
	button.pressed.emit()
	_check(_progress().stage(id) == 0 and not _ui.has_modal(), "observation action respects pause")
	_main.call("_set_paused", false)
	button.pressed.emit()
	_check(_ui.has_modal() and _progress().stage(id) == 1, "reading observation introduction advances exactly one step")
	_ui.close_modal()
	for view_index in [1, 0]:
		var saved: Dictionary = _progress().serialize()
		_main.call("_show_views")
		await _layout()
		var actions := _ui.get("_modal_actions") as VBoxContainer
		_check(actions.get_child_count() == 3, "observation view menu has both previews and return")
		if actions.get_child_count() != 3:
			_ui.close_modal()
			return
		var preview := actions.get_child(view_index) as Button
		_check(preview.icon != null and "观景记录" in preview.text and "返回地面" not in preview.text, "observation preview describes actual mode")
		preview.pressed.emit()
		await _scene(id)
		_check(_main.get("_view_index") == view_index and _progress().serialize() == saved, "observation view switch preserves unfinished record")
		_check(not (_ui.get("_ground_button") as Button).visible, "both observation views hide ground return")
		_main.call("_return_to_ground")
		_main.call("_request_walk", Vector2(640, 660))
		_check(not _main.get("_transitioning") and not _traveler.is_walking(), "observation controls never create a walking transition")
		_check(not (_main.get("_pathfinder") as IsoPathfinder).is_world_walkable(Vector2(640, 660)), "observation ground stays non-walkable")
		if view_index == 1:
			button.pressed.emit()
			_check(_ui.has_modal() and _progress().state(id).choice == -1, "observation choice waits for user selection")
			_main.call("_on_postcard_choice", -1)
			_main.call("_on_postcard_choice", 99)
			_check(_progress().state(id).choice == -1, "invalid observation choices rejected")
			((_ui.get("_modal_actions") as VBoxContainer).get_child(1) as Button).pressed.emit()
			_check(_progress().stage(id) == 2 and _progress().state(id).choice == 1, "observation selection saves a real impression")
			_ui.close_modal()
		await _capture(id + "-view-%d" % view_index)
	button.pressed.emit()
	_check(_main.get("_postcard_context") == "tour_record" and _progress().stage(id) == 2, "observation record requires confirmation")
	_ui.close_modal()
	_check(_progress().stage(id) == 2, "cancelling observation record preserves unfinished state")
	button.pressed.emit()
	((_ui.get("_modal_actions") as VBoxContainer).get_child(0) as Button).pressed.emit()
	_check(_progress().stage(id) == 3 and not button.visible, "observation stop completes after explicit confirmation")
	_ui.close_modal()
	var completed: Dictionary = _progress().serialize()
	_main.call("_select_view", 1)
	await _scene(id)
	_check(_progress().serialize() == completed and not button.visible, "completed observation record shared across views")
	_main.call("_show_current_journey")
	_check(_ui.has_modal(), "completed observation record remains readable")
	await _capture(id + "-record")
	_ui.close_modal()

func _verify_single_ground_return(id: String) -> void:
	var saved: Dictionary = _progress().serialize()
	var position := _traveler.global_position
	if id == "angkor_ta_som":
		_check(not (_main.get("_pathfinder") as IsoPathfinder).is_world_walkable(Vector2(640, 600)), "sanctuary steps and masonry remain outside walking floor")
	if id == "angkor_neak_pean":
		var pathfinder := _main.get("_pathfinder") as IsoPathfinder
		_check(not pathfinder.is_world_walkable(Vector2(200, 650)) and not pathfinder.is_world_walkable(Vector2(1100, 650)), "both reservoir sides remain outside the boardwalk")
	_main.call("_select_view", 1)
	await _scene(id)
	_check(_main.get("_panorama") and not _traveler.visible, "pond view shows no walking actor")
	_check((_main.get("_targets") as Dictionary).is_empty(), "pond view has no walking interactions")
	_check(not (_main.get("_pathfinder") as IsoPathfinder).is_world_walkable(Vector2(640, 660)), "green pond water is never walkable")
	_check(not (_ui.get("_exploration_button") as Button).visible, "pond view cannot bypass ground activities")
	_main.call("_guide_next_angkor_target")
	_main.call("_request_walk", Vector2(640, 660))
	_check(not _traveler.is_walking() and _progress().serialize() == saved, "pond actions grant no remote progress")
	var button := _ui.get("_ground_button") as Button
	_check(button.visible, "pond view provides direct causeway return")
	button.pressed.emit()
	await _scene(id)
	_check(_main.get("_view_index") == 0 and _traveler.visible, "pond return restores causeway view")
	_check(_traveler.global_position.distance_to(position) < 1, "pond return restores last causeway position")
	_check(_progress().serialize() == saved and _progress().stage(id) == 1, "pond round-trip preserves unfinished record")
	await _approach("tour_info")
	_check(_ui.has_modal(), "causeway interactions still work after pond return")
	_ui.close_modal()


func _verify_ground_view_return(id: String) -> void:
	var saved: Dictionary = _progress().serialize()
	var original_position := _traveler.global_position
	_main.call("_select_view", 1)
	await _scene(id)
	_check(not _main.get("_panorama") and _traveler.visible, "second gate view supports ground exploration")
	_check(not (_ui.get("_ground_button") as Button).visible, "ground view has no panorama return button")
	await _approach("tour_info")
	_ui.close_modal()
	var second_position := _traveler.global_position
	_main.call("_select_view", 0)
	await _scene(id)
	_check(_traveler.global_position.distance_to(original_position) < 1, "first gate view restores its own position")
	_main.call("_select_view", 1)
	await _scene(id)
	_check(_traveler.global_position.distance_to(second_position) < 1, "second gate view restores its own position")
	_check(_progress().serialize() == saved and _progress().stage(id) == 1, "ground view round-trip preserves incomplete travel record")
	_check(not (_main.get("_pathfinder") as IsoPathfinder).is_world_walkable(Vector2(640, 540)), "gate passage and ruins remain outside ground navigation")
	_main.call("_select_view", 0)
	await _scene(id)


func _verify_view_return(id: String) -> void:
	var saved: Dictionary = _progress().serialize()
	var original_position := _traveler.global_position
	_main.call("_select_view", 2)
	await _scene(id)
	await _approach("tour_info")
	_ui.close_modal()
	var ground_position := _traveler.global_position
	_check(ground_position.distance_to(original_position) > 20, "ground views have independent positions: " + id)
	_main.call("_select_view", 1)
	await _scene(id)
	var return_button := _ui.get("_ground_button") as Button
	_check(return_button.is_visible_in_tree(), "panorama offers direct ground return: " + id)
	_check(not (_ui.get("_exploration_button") as Button).visible, "panorama hides walking guidance: " + id)
	_main.call("_guide_next_angkor_target")
	_check(not _traveler.is_walking() and _progress().serialize() == saved, "panorama guidance cannot walk or grant progress: " + id)
	await _layout()
	_check(Rect2(0, 0, 1280, 720).encloses((_ui.get("_quest_panel") as Control).get_global_rect()), "panorama return panel fits viewport: " + id)
	_check(not _traveler.visible and not _traveler.is_walking(), "panorama leaves no moving actor: " + id)
	_main.call("_set_paused", true)
	return_button.pressed.emit()
	_check(not _main.get("_transitioning"), "ground return respects pause: " + id)
	_main.call("_set_paused", false)
	return_button.pressed.emit()
	return_button.pressed.emit()
	await _scene(id)
	_check(_main.get("_view_index") == 2, "ground return selects previous ground view: " + id)
	_check(_traveler.visible and not return_button.visible, "ground return restores walking HUD: " + id)
	_check(_traveler.global_position.distance_to(ground_position) < 1, "ground return restores last walking position: " + id)
	_check(_progress().serialize() == saved and _progress().stage(id) == 1, "unfinished record survives panorama without completion: " + id)
	_main.call("_select_view", 0)
	await _scene(id)
	_check(_traveler.global_position.distance_to(original_position) < 1, "other ground view retains its own position: " + id)
	_check((_main.get("_pathfinder") as IsoPathfinder).is_world_walkable(_traveler.global_position), "restored position is walkable: " + id)
	await _approach("tour_info")
	_check(_ui.has_modal(), "restored view still supports physical interaction: " + id)
	_ui.close_modal()


func _verify_views(id: String) -> void:
	var saved: Dictionary = _progress().serialize()
	_check(Catalog.views(id).size() == (2 if id in ["angkor_banteay_kdei", "angkor_preah_khan", "angkor_neak_pean", "angkor_ta_som"] else 4), "all reviewed perspectives available: " + id)
	for index in range(Catalog.views(id).size()):
		_check(ResourceLoader.exists(Catalog.background_path(id, index)), "view art ships: %s/%d" % [id, index])
		(_ui.get("_view_button") as Button).pressed.emit()
		await _layout()
		_check(_ui.has_modal(), "view menu opens")
		_check(Rect2(0, 0, 1280, 720).encloses((_ui.get("_modal_panel") as Control).get_global_rect()), "view menu fits viewport")
		var actions := _ui.get("_modal_actions") as VBoxContainer
		_check(actions.get_child_count() == Catalog.views(id).size() + 1, "all view choices and return action are available")
		if actions.get_child_count() != Catalog.views(id).size() + 1:
			_ui.close_modal()
			return
		var button := actions.get_child(index) as Button
		_check(button.icon != null and button.icon.resource_path == Catalog.background_path(id, index), "view preview matches destination painting")
		var panorama: bool = World.layout(id, index).get("panorama", false)
		_check(("静静观景" if panorama else "地面漫步") in button.text, "view choice describes actual navigation mode")
		_check(Rect2(0, 0, 1280, 720).encloses(button.get_global_rect()), "view choice remains on screen")
		await _capture(id + "-view-menu-%d" % index)
		button.pressed.emit()
		await _scene(id)
		_check(_main.get("_view_index") == index, "view button reaches selected painting")
		_check(_progress().serialize() == saved, "perspectives share progress without granting or resetting it")
		var finder := _main.get("_pathfinder") as IsoPathfinder
		if _main.get("_panorama"):
			_check(not _traveler.visible and (_main.get("_targets") as Dictionary).is_empty(), "reflection panorama has no actor or walking targets")
			_check(not finder.is_world_walkable(Vector2(400, 660)), "reflection water is not walkable")
			_main.call("_request_walk", Vector2(640, 660))
			_check(not _traveler.is_walking(), "panorama clicks cannot move onto water")
		else:
			_check(_traveler.visible and finder.is_world_walkable(_traveler.position), "walkable view arrival")
			for target_id: String in ["tour_info", "tour_activity", "tour_record"]:
				await _approach(target_id)
				_check(_ui.has_modal(), "view target can be reached: " + target_id)
				_ui.close_modal()
		await _capture(id + "-view-%d" % index)
	_main.call("_select_view", -1)
	_main.call("_select_view", 99)
	_check(not _main.get("_transitioning"), "invalid views rejected")
	_main.call("_select_view", 0)
	await _scene(id)
	_check(_progress().serialize() == saved, "returning to main view preserves completed record")

func _stop_button(parent: Node, title: String) -> Button:
	for child in parent.get_children():
		if child is Button and title in child.text: return child
		var found := _stop_button(child, title)
		if found != null: return found
	return null

func _approach(id: String, guided: bool = false) -> void:
	await physics_frame
	var target := (_main.get("_targets") as Dictionary)[id] as ExplorationTarget
	if guided:
		var button := _ui.get("_exploration_button") as Button
		_check(button.is_visible_in_tree() and target.display_name in button.text, "guidance names next required target: " + id)
		var before := _traveler.global_position
		var progress_before: Dictionary = _progress().serialize()
		_main.call("_set_paused", true)
		button.pressed.emit()
		_check(not _traveler.is_walking() and not _ui.has_modal(), "guidance respects pause: " + id)
		_main.call("_set_paused", false)
		button.pressed.emit()
		_check(_traveler.global_position == before, "guidance never teleports the traveler: " + id)
		if before.distance_to(target.stand_position) > 26:
			_check(_progress().serialize() == progress_before and not _ui.has_modal(), "guidance waits for physical arrival: " + id)
		if _main.get("_scene_id") == "angkor_ta_prohm" and id == "tour_info":
			_main.call("_show_views")
			_check(not _traveler.is_walking() and _main.get("_pending_target") == null, "view menu cancels guided walking")
			button.pressed.emit()
			_check(not _traveler.is_walking(), "guidance cannot run through an open modal")
			_ui.close_modal()
			button.pressed.emit()
	else:
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
