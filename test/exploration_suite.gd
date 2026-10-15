extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const PATHFINDER_SCRIPT = preload("res://scripts/game/iso_pathfinder.gd")
const SIGN_TEXT := "西贡中央邮局是胡志明市最具代表性的历史建筑之一，以其宏伟的空间和法国殖民时期的建筑风格闻名。"
const MAILBOX_TEXT := "这个旧邮筒似乎已经在这里很久了。不知道它曾经寄出过多少封信。"
const REPLY_A := "那你一定要看看这座邮局。这里有很多值得发现的建筑细节。"
const REPLY_B := "那你来对地方了。西贡的每一条街道，似乎都有自己的故事。"

var _checks := 0
var _failures: Array[String] = []
var _original_postcard_progress: Dictionary


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_original_postcard_progress = root.get_node("SaveStore").get_postcard_progress()
	var main := MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	_check(str(main.get("_scene_id")) == "outdoor", "starts in the exterior street")
	var traveler := main.get("_traveler") as Traveler
	var ui := main.get("_ui") as ExplorationUI
	_check(traveler != null, "player traveler exists")
	_check(ui != null, "travel UI exists")
	if traveler == null or ui == null:
		await _finish(main)
		return

	var hint_panel := ui.get("_hint_panel") as PanelContainer
	_check(hint_panel != null and hint_panel.mouse_filter == Control.MOUSE_FILTER_IGNORE, "the HUD hint does not intercept world clicks")

	var targets: Dictionary = main.get("_targets")
	for target_id: String in ["post_office_info", "old_mailbox", "photographer", "post_office_door"]:
		var target := targets.get(target_id) as ExplorationTarget
		_check(target != null, "exterior target: " + target_id)
		if target != null:
			_check(target.input_pickable and target.get_node_or_null("ClickTarget") != null, "real click hitbox: " + target_id)

	var photographer_hit_test := targets.get("photographer") as ExplorationTarget
	_check(photographer_hit_test != null and main.call("_target_at", photographer_hit_test.global_position) == photographer_hit_test, "a real point query picks the photographer hitbox")

	_test_astar_obstacle_detour()
	_test_facing(traveler)
	await _test_collision_safe_waypoints()
	var pathfinder := main.get("_pathfinder") as IsoPathfinder
	_test_wall_routes(pathfinder, traveler.global_position, [Vector2(420, 300), Vector2(900, 350), Vector2(608, 260)], "outdoor")
	var porch_route := pathfinder.find_path(traveler.global_position, Vector2(608, 416))
	_check(not porch_route.is_empty() and porch_route[-1].distance_to(Vector2(608, 416)) < 1.0, "central porch remains reachable")
	var origin := traveler.global_position
	var first_destination := Vector2(1090.0, 430.0)
	var first_route := pathfinder.find_path(origin, first_destination)
	_check(not first_route.is_empty(), "a distant exterior destination has a route")
	_check(_route_is_clear(pathfinder, origin, first_route), "the exterior route stays in walkable cells")
	main.call("_request_walk", first_destination)
	for _frame in range(8):
		await physics_frame
	_check(traveler.global_position.distance_to(origin) > 1.0, "click-to-move changes the character position")
	main.call("_request_walk", Vector2(540.0, 560.0))
	_check(traveler.is_walking(), "a second click replaces the active route")
	_check(traveler.current_destination().distance_to(Vector2(540.0, 560.0)) < 40.0, "the replacement route targets the new click")
	traveler.cancel_path()

	var sign_target := targets.get("post_office_info") as ExplorationTarget
	_press_target(sign_target)
	_check(await _wait_for_modal(ui, SIGN_TEXT), "the sign opens after the traveler approaches")
	_check(traveler.global_position.distance_to(sign_target.stand_position) <= 26.0, "the player stops at the sign interaction point")
	ui.close_modal()
	await process_frame

	var mailbox_target := targets.get("old_mailbox") as ExplorationTarget
	_press_target(mailbox_target)
	_check(await _wait_for_modal(ui, MAILBOX_TEXT), "the mailbox opens its requested text")
	_check(traveler.global_position.distance_to(mailbox_target.stand_position) <= 26.0, "the player stops beside the mailbox")
	ui.close_modal()
	await process_frame

	var photographer := targets.get("photographer") as ExplorationTarget
	_press_target(photographer)
	_check(await _wait_for_modal(ui, "第一次来西贡吗？"), "the photographer starts the requested conversation")
	var actions := ui.get("_modal_actions") as VBoxContainer
	if actions.get_child_count() >= 2:
		(actions.get_child(0) as Button).pressed.emit()
		await process_frame
		_check(_modal_body(ui) == REPLY_A, "the exploration choice returns the requested response")
	else:
		_check(false, "both conversation choices are present")
	ui.close_modal()
	await process_frame

	photographer = (main.get("_targets") as Dictionary).get("photographer") as ExplorationTarget
	_press_target(photographer)
	_check(await _wait_for_modal(ui, "第一次来西贡吗？"), "the photographer can be spoken to again")
	actions = ui.get("_modal_actions") as VBoxContainer
	var history_choice: Button
	for child in actions.get_children():
		if child is Button and (child as Button).text == "我对这座城市的历史很感兴趣。":
			history_choice = child as Button
	if history_choice != null:
		history_choice.pressed.emit()
		await process_frame
		_check(_modal_body(ui) == REPLY_B, "the history choice returns the requested response")
	else:
		_check(false, "both conversation choices are present in a new conversation")
	ui.close_modal()
	await process_frame

	var entrance := (main.get("_targets") as Dictionary).get("post_office_door") as ExplorationTarget
	_press_target(entrance)
	var entrance_opened := await _wait_for_scene(main, "indoor")
	_check(entrance_opened, "the entrance opens the post-office hall")
	_check(traveler.global_position.distance_to(Vector2(640.0, 575.0)) < 2.0, "indoor entry spawns beside the lobby entrance")
	pathfinder = main.get("_pathfinder") as IsoPathfinder
	_test_wall_routes(pathfinder, traveler.global_position, [Vector2(250, 280), Vector2(476, 270), Vector2(1000, 350)], "indoor")
	var exit_target := (main.get("_targets") as Dictionary).get("outdoor_exit") as ExplorationTarget
	_check(exit_target != null, "the hall has a clickable outdoor exit")
	if exit_target != null:
		_press_target(exit_target)
		_check(await _wait_for_scene(main, "outdoor"), "the hall exit returns to the street")
		_check(traveler.global_position.distance_to(Vector2(608.0, 432.0)) < 2.0, "the street return spawns by the doorway")
		var return_origin := traveler.global_position
		main.call("_request_walk", Vector2(540.0, 386.0))
		_check(traveler.is_walking(), "the traveler stays controllable after switching scenes")
		for _frame in range(8):
			await physics_frame
		_check(traveler.global_position.distance_to(return_origin) > 1.0, "the returned traveler can move outside")

	await _finish(main)


func _test_facing(traveler: Traveler) -> void:
	for direction: Vector2 in [Vector2(32, 16), Vector2(-32, 16)]:
		_check(traveler.call("_direction_row", direction) == 0, "downward isometric diagonals use the front pose")
	for direction: Vector2 in [Vector2(32, -16), Vector2(-32, -16)]:
		_check(traveler.call("_direction_row", direction) == 2, "upward isometric diagonals use the back pose")
	var sprite := traveler.get_node("TravelerFrames") as AnimatedSprite2D
	traveler.call("_play_walk", Vector2.LEFT)
	_check(sprite.animation == "walk_left" and sprite.flip_h, "left travel mirrors the right-facing side art")
	traveler.cancel_path()
	_check(sprite.animation == "idle_left" and sprite.flip_h, "left idle retains the mirrored facing")
	traveler.call("_play_walk", Vector2.RIGHT)
	_check(sprite.animation == "walk_right" and not sprite.flip_h, "right travel uses the unmirrored side art")
	traveler.call("_play_walk", Vector2.UP)
	_check(sprite.animation == "walk_up" and not sprite.flip_h, "back travel clears the side mirror")
	traveler.cancel_path()


func _test_wall_routes(pathfinder: IsoPathfinder, start: Vector2, wall_clicks: Array[Vector2], context: String) -> void:
	for wall in wall_clicks:
		_check(not pathfinder.is_world_walkable(wall), context + " wall is blocked: " + str(wall))
		var route := pathfinder.find_path(start, wall)
		_check(not route.is_empty(), context + " wall click resolves to reachable ground")
		_check(_route_is_clear(pathfinder, start, route), context + " wall route avoids the facade")
		if not route.is_empty():
			_check(route[-1].distance_to(wall) > 18.0, context + " wall destination keeps actor clearance")


func _test_collision_safe_waypoints() -> void:
	# Isolate a thin blocker close enough to trigger the old 3.5px waypoint snap.
	var arena := Node2D.new()
	arena.position = Vector2(3000, 3000)
	root.add_child(arena)
	var traveler := Traveler.new()
	arena.add_child(traveler)
	traveler.set_physics_process(false)
	var wall := StaticBody2D.new()
	wall.position = Vector2(10.5, -9)
	var hitbox := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(1, 100)
	hitbox.shape = shape
	wall.add_child(hitbox)
	arena.add_child(wall)
	await physics_frame
	await physics_frame
	traveler.set_path(PackedVector2Array([arena.global_position + Vector2(3, 0)]))
	var blocked_routes: Array[bool] = []
	traveler.route_blocked.connect(func() -> void: blocked_routes.append(true))
	for frame in range(24):
		traveler.call("_physics_process", 1.0 / 60.0)
		await physics_frame
	_check(traveler.position.x < 1.1, "a short waypoint cannot snap the actor into a thin wall")
	_check(not blocked_routes.is_empty(), "a blocked waypoint stops and reports the collision")
	arena.remove_child(wall)
	wall.free()
	await physics_frame
	traveler.position = Vector2.ZERO
	traveler.set_path(PackedVector2Array([arena.global_position + Vector2(2, 0)]))
	traveler.call("_physics_process", 1.0 / 60.0)
	_check(traveler.position.distance_to(Vector2(2, 0)) <= 0.1, "a short unobstructed waypoint reaches its target without overshoot")
	_check(not traveler.is_walking(), "short routes complete through physics")
	traveler.position = Vector2.ZERO
	traveler.set_path(PackedVector2Array([arena.global_position + Vector2(100, 0)]))
	traveler.call("_physics_process", 1.0 / 60.0)
	_check(traveler.position.length() <= traveler.walk_speed / 60.0 + 0.01, "each frame respects the configured movement speed")
	arena.queue_free()
	await process_frame


func _test_astar_obstacle_detour() -> void:
	var pathfinder := PATHFINDER_SCRIPT.new() as IsoPathfinder
	var obstacles: Array[Rect2] = [Rect2(Vector2(260.0, 180.0), Vector2(60.0, 280.0))]
	pathfinder.configure(Rect2(Vector2(80.0, 80.0), Vector2(480.0, 480.0)), obstacles)
	var start := Vector2(150.0, 320.0)
	var destination := Vector2(450.0, 320.0)
	var route := pathfinder.find_path(start, destination)
	_check(not route.is_empty(), "A* finds a route around a blocked corridor")
	_check(route.size() >= 2, "the blocked corridor requires an actual detour")
	_check(not route.is_empty() and route[route.size() - 1].distance_to(destination) < 40.0, "the detour reaches the requested destination")
	_check(_route_is_clear(pathfinder, start, route), "the smoothed route never cuts through the inflated wall")


func _route_is_clear(pathfinder: IsoPathfinder, start: Vector2, route: PackedVector2Array) -> bool:
	var cursor := start
	for point in route:
		var steps := maxi(1, ceili(cursor.distance_to(point) / 6.0))
		for step in range(steps + 1):
			if not pathfinder.is_world_walkable(cursor.lerp(point, float(step) / float(steps))):
				return false
		cursor = point
	return true


func _press_target(target: ExplorationTarget) -> void:
	if target == null:
		return
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	target.call("_on_input_event", get_root(), click, 0)


func _wait_for_modal(ui: ExplorationUI, expected_text: String, max_frames: int = 720) -> bool:
	for _frame in range(max_frames):
		if ui.has_modal() and _modal_body(ui) == expected_text:
			return true
		await physics_frame
	return ui.has_modal() and _modal_body(ui) == expected_text


func _wait_for_scene(main: Node, expected_scene: String, max_frames: int = 180) -> bool:
	for _frame in range(max_frames):
		await physics_frame
		if str(main.get("_scene_id")) == expected_scene and not bool(main.get("_transitioning")):
			return true
	return str(main.get("_scene_id")) == expected_scene and not bool(main.get("_transitioning"))


func _modal_body(ui: ExplorationUI) -> String:
	var label := ui.get("_modal_body") as Label
	return label.text if label != null else ""


func _check(condition: bool, context: String) -> void:
	_checks += 1
	if not condition and context not in _failures:
		_failures.append(context)


func _finish(main: Node) -> void:
	root.get_node("SaveStore").set_postcard_progress(_original_postcard_progress)
	main.queue_free()
	await process_frame
	if _failures.is_empty():
		print("[grand-tour-tests] PASS: %d finite gameplay checks" % _checks)
		quit(0)
	else:
		for failure: String in _failures:
			push_error("[grand-tour-tests] " + failure)
		print("[grand-tour-tests] FAIL: %d failures across %d checks" % [_failures.size(), _checks])
		quit(1)
