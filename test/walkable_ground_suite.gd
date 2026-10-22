extends SceneTree

const MAIN := preload("res://scenes/main.tscn")
var _checks := 0
var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var main := MAIN.instantiate()
	root.add_child(main)
	await physics_frame
	await physics_frame
	(main.get("_ui") as Control).call("close_modal")
	var traveler := main.get("_traveler") as Traveler
	var floor: PackedVector2Array = main.call("_outdoor_floor")
	var pathfinder := main.get("_pathfinder") as IsoPathfinder
	var collision := main.get_node("WorldColliders/WalkableGroundBoundary/SharedFloorOutline") as CollisionPolygon2D
	_check(collision.polygon == floor and collision.build_mode == CollisionPolygon2D.BUILD_SEGMENTS, "outdoor navigation and physical perimeter use the same ground outline")
	for point: Vector2 in [Vector2(720, 430), Vector2(800, 455), Vector2(1000, 510), Vector2(580, 340), Vector2(300, 320), Vector2(1150, 650), Vector2(120, 570)]:
		_check(not pathfinder.is_world_walkable(point), "building/fence/trees are outside walkable ground: " + str(point))
		var route := pathfinder.find_path(Vector2(608, 432), point)
		_check(not route.is_empty(), "a blocked click finds reachable paving: " + str(point))
		_check(_inside_route(floor, Vector2(608, 432), route), "blocked click cannot shortcut across the fence: " + str(point))
	traveler.global_position = Vector2(608, 432)
	await physics_frame
	await _walk(main, Vector2(862, 540), floor)
	await _capture(main, "recorded-door-to-photographer", floor)
	await _walk(main, Vector2(608, 416), floor)
	await _walk(main, Vector2(800, 530), floor)
	await _walk(main, Vector2(400, 542), floor)
	# Bypass the planner intentionally: physics must still stop an unsafe route.
	traveler.global_position = Vector2(800, 580)
	await physics_frame
	traveler.set_path(PackedVector2Array([Vector2(800, 350)]))
	for frame in range(180):
		await physics_frame
		if not traveler.is_walking():
			break
	_check(not traveler.is_walking(), "an unsafe direct route stops at the physical perimeter")
	_check(Geometry2D.is_point_in_polygon(traveler.global_position, floor), "physical collision keeps the traveler on the public side of the fence")
	_check(traveler.global_position.distance_to(Vector2(800, 350)) > 100.0, "physics cannot reach a destination behind the fence")
	main.call("_setup_scene", "indoor", Vector2(640, 575))
	await physics_frame
	await physics_frame
	floor = main.call("_indoor_floor")
	pathfinder = main.get("_pathfinder") as IsoPathfinder
	collision = main.get_node("WorldColliders/WalkableGroundBoundary/SharedFloorOutline") as CollisionPolygon2D
	_check(collision.polygon == floor, "indoor navigation and physical perimeter share the floor outline")
	for point: Vector2 in [Vector2(200, 300), Vector2(900, 330), Vector2(1100, 480), Vector2(350, 680)]:
		_check(not pathfinder.is_world_walkable(point), "indoor walls and foreground railings are blocked: " + str(point))
		var route := pathfinder.find_path(traveler.global_position, point)
		_check(not route.is_empty() and _inside_route(floor, traveler.global_position, route), "an indoor wall click resolves entirely on the hall floor")
	await _walk(main, Vector2(770, 460), floor)
	await _walk(main, Vector2(640, 575), floor)
	await _capture(main, "hall-floor-boundary", floor)
	main.queue_free()
	await process_frame
	if _failures.is_empty():
		print("[ground-tests] PASS: %d shared-floor, recorded-route and collision checks" % _checks)
		quit(0)
	else:
		for failure in _failures:
			push_error("[ground-tests] " + failure)
		quit(1)


func _walk(main: Node, destination: Vector2, floor: PackedVector2Array) -> void:
	var traveler := main.get("_traveler") as Traveler
	main.call("_request_walk", destination)
	var stayed_inside := true
	for frame in range(900):
		await physics_frame
		stayed_inside = stayed_inside and Geometry2D.is_point_in_polygon(traveler.global_position, floor)
		if not traveler.is_walking():
			break
	_check(stayed_inside, "every physics frame stays on the floor en route to " + str(destination))
	_check(traveler.global_position.distance_to(destination) < 1.0, "the safe route actually reaches " + str(destination))


func _inside_route(floor: PackedVector2Array, start: Vector2, route: PackedVector2Array) -> bool:
	var cursor := start
	for point in route:
		var steps := maxi(1, ceili(cursor.distance_to(point) / 2.0))
		for step in range(steps + 1):
			var sample := cursor.lerp(point, float(step) / steps)
			if not Geometry2D.is_point_in_polygon(sample, floor):
				return false
			for index in range(floor.size()):
				var edge := Geometry2D.get_closest_point_to_segment(sample, floor[index], floor[(index + 1) % floor.size()])
				if sample.distance_to(edge) <= 23.9:
					return false
		cursor = point
	return true


func _capture(main: Node, name: String, floor: PackedVector2Array) -> void:
	var directory := OS.get_environment("GRANDTOUR_CAPTURE_DIR")
	if directory.is_empty():
		return
	DirAccess.make_dir_recursive_absolute(directory)
	var overlay := Polygon2D.new()
	overlay.polygon = floor
	overlay.color = Color(0.2, 0.8, 0.4, 0.22)
	(main.get("_background_root") as Node2D).add_child(overlay)
	var edge := Line2D.new()
	edge.points = floor.duplicate()
	edge.add_point(floor[0])
	edge.width = 3
	edge.default_color = Color(0.1, 0.8, 0.35)
	overlay.add_child(edge)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(directory.path_join(name + ".png"))
	overlay.queue_free()
	await process_frame


func _check(condition: bool, context: String) -> void:
	_checks += 1
	if not condition and context not in _failures:
		_failures.append(context)
