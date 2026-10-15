extends RefCounted
class_name IsoPathfinder

const GRID_SIZE := 64
const ACTOR_CLEARANCE := 24.0

var _astar: AStarGrid2D
var _graph: AStar2D
var _walk_rect := Rect2()
var _obstacles: Array[Rect2] = []
var _walls: Array[PackedVector2Array] = []
var _floor := PackedVector2Array()


func configure(walk_rect: Rect2, obstacles: Array[Rect2], walls: Array[PackedVector2Array] = [], floor_outline: PackedVector2Array = PackedVector2Array()) -> void:
	_walk_rect = walk_rect
	_obstacles = obstacles.duplicate()
	_walls = walls.duplicate()
	_floor = floor_outline.duplicate()
	_astar = AStarGrid2D.new()
	_astar.region = Rect2i(0, 0, GRID_SIZE, GRID_SIZE)
	_astar.cell_size = Vector2i.ONE
	_astar.cell_shape = AStarGrid2D.CELL_SHAPE_SQUARE
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	_astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	_astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	_astar.update()
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var id := Vector2i(x, y)
			var point := cell_to_world(id)
			if not _inside_floor(point) or _inside_expanded_obstacle(point):
				_astar.set_point_solid(id, true)
	# Validate edges as well as cell centers: a slanted wall can cross a grid edge.
	_graph = AStar2D.new()
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var id := Vector2i(x, y)
			if not _astar.is_point_solid(id):
				_graph.add_point(_point_id(id), cell_to_world(id))
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var id := Vector2i(x, y)
			if _astar.is_point_solid(id):
				continue
			for offset: Vector2i in [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, -1)]:
				var neighbor := id + offset
				if not _inside_grid(neighbor) or _astar.is_point_solid(neighbor):
					continue
				if offset.x != 0 and offset.y != 0:
					if _astar.is_point_solid(id + Vector2i(offset.x, 0)) or _astar.is_point_solid(id + Vector2i(0, offset.y)):
						continue
				if _line_is_clear(cell_to_world(id), cell_to_world(neighbor)):
					_graph.connect_points(_point_id(id), _point_id(neighbor))


func find_path(start_world: Vector2, requested_world: Vector2) -> PackedVector2Array:
	if _astar == null:
		return PackedVector2Array()
	var start_id := _nearest_start_id(start_world)
	if start_id == Vector2i(-1, -1):
		return PackedVector2Array()

	var candidates: Array[Dictionary] = []
	var requested_id := world_to_cell(requested_world)
	var requested_is_walkable := is_world_walkable(requested_world)
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var id := Vector2i(x, y)
			if _astar.is_point_solid(id):
				continue
			var point := cell_to_world(id)
			# The nearest center is not always the cell containing a click on a 2:1 grid.
			# Prefer the containing cell so valid ground clicks reach the exact position.
			var distance := -1.0 if requested_is_walkable and id == requested_id else point.distance_squared_to(requested_world)
			candidates.append({"id": id, "distance": distance})
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a["distance"]) < float(b["distance"])
	)

	# A clicked wall/facade or a cell beyond the walkable footprint resolves to the
	# nearest reachable point, even when the closest ground belongs to another area.
	for index in range(candidates.size()):
		var target_id: Vector2i = candidates[index]["id"]
		var id_path := _graph.get_id_path(_point_id(start_id), _point_id(target_id))
		if id_path.is_empty():
			continue
		var points := PackedVector2Array()
		var start_center := cell_to_world(start_id)
		if start_world.distance_to(start_center) > 3.0:
			points.append(start_center)
		for path_index in range(1, id_path.size()):
			points.append(_graph.get_point_position(id_path[path_index]))
		if target_id == world_to_cell(requested_world) and is_world_walkable(requested_world):
			points.append(requested_world)
		var route := _smooth_path(start_world, points)
		if not route.is_empty():
			return route
	return PackedVector2Array()


func is_world_walkable(point: Vector2) -> bool:
	if _astar == null or not _inside_floor(point) or _inside_expanded_obstacle(point):
		return false
	var id := world_to_cell(point)
	return _inside_grid(id) and not _astar.is_point_solid(id)


func cell_to_world(id: Vector2i) -> Vector2:
	# Logical square-grid neighbours become the two diagonal axes of an isometric plane.
	return Vector2(float(id.x - id.y) * 32.0, float(id.x + id.y - 32) * 16.0)


func world_to_cell(point: Vector2) -> Vector2i:
	var x := point.x / 64.0
	var y := point.y / 32.0
	return Vector2i(roundi(x + y + 16.0), roundi(y - x + 16.0))


func _nearest_start_id(point: Vector2) -> Vector2i:
	var candidates: Array[Dictionary] = []
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var id := Vector2i(x, y)
			if _astar.is_point_solid(id):
				continue
			var cell_point := cell_to_world(id)
			candidates.append({"id": id, "distance": cell_point.distance_squared_to(point)})
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a["distance"]) < float(b["distance"])
	)
	var limit := mini(candidates.size(), 36)
	for index in range(limit):
		var id: Vector2i = candidates[index]["id"]
		var candidate := cell_to_world(id)
		if _line_is_clear(point, candidate):
			return id
	return Vector2i(-1, -1)


func _smooth_path(start: Vector2, raw: PackedVector2Array) -> PackedVector2Array:
	if raw.is_empty():
		return raw
	var simplified := PackedVector2Array()
	var anchor := start
	var index := 0
	while index < raw.size():
		var farthest := index
		for candidate in range(raw.size() - 1, index - 1, -1):
			if _line_is_clear(anchor, raw[candidate]):
				farthest = candidate
				break
		if farthest == index and not _line_is_clear(anchor, raw[index]):
			# A grid edge can graze a slanted wall between its endpoints.
			return PackedVector2Array()
		else:
			simplified.append(raw[farthest])
			anchor = raw[farthest]
			index = farthest + 1
	return simplified


func _line_is_clear(from: Vector2, to: Vector2) -> bool:
	# Reject boundary crossings exactly, including segments between sampled cells.
	if not _floor.is_empty() and not _segment_avoids_edges(from, to, _floor):
		return false
	for wall in _walls:
		if not _segment_avoids_edges(from, to, wall):
			return false
	var distance := from.distance_to(to)
	var samples := maxi(1, ceili(distance / 8.0))
	for sample in range(samples + 1):
		var point := from.lerp(to, float(sample) / float(samples))
		if not _inside_floor(point) or _inside_expanded_obstacle(point):
			return false
		var id := world_to_cell(point)
		if not _inside_grid(id) or _astar.is_point_solid(id):
			return false
	return true


func _inside_expanded_obstacle(point: Vector2) -> bool:
	for obstacle in _obstacles:
		if obstacle.grow(ACTOR_CLEARANCE).has_point(point):
			return true
	for wall in _walls:
		if Geometry2D.is_point_in_polygon(point, wall):
			return true
		for index in range(wall.size()):
			var nearest := Geometry2D.get_closest_point_to_segment(point, wall[index], wall[(index + 1) % wall.size()])
			if point.distance_to(nearest) <= ACTOR_CLEARANCE:
				return true
	return false


func _inside_grid(id: Vector2i) -> bool:
	return id.x >= 0 and id.y >= 0 and id.x < GRID_SIZE and id.y < GRID_SIZE


func _point_id(id: Vector2i) -> int:
	return id.x * GRID_SIZE + id.y


func _inside_floor(point: Vector2) -> bool:
	if not _walk_rect.has_point(point):
		return false
	if _floor.is_empty():
		return true
	if not Geometry2D.is_point_in_polygon(point, _floor):
		return false
	for index in range(_floor.size()):
		var nearest := Geometry2D.get_closest_point_to_segment(point, _floor[index], _floor[(index + 1) % _floor.size()])
		if point.distance_to(nearest) <= ACTOR_CLEARANCE:
			return false
	return true


func _segment_avoids_edges(from: Vector2, to: Vector2, polygon: PackedVector2Array) -> bool:
	for index in range(polygon.size()):
		var a := polygon[index]
		var b := polygon[(index + 1) % polygon.size()]
		if Geometry2D.segment_intersects_segment(from, to, a, b) != null:
			return false
		# Closest points of two non-intersecting segments include an endpoint.
		if from.distance_to(Geometry2D.get_closest_point_to_segment(from, a, b)) <= ACTOR_CLEARANCE:
			return false
		if to.distance_to(Geometry2D.get_closest_point_to_segment(to, a, b)) <= ACTOR_CLEARANCE:
			return false
		if a.distance_to(Geometry2D.get_closest_point_to_segment(a, from, to)) <= ACTOR_CLEARANCE:
			return false
		if b.distance_to(Geometry2D.get_closest_point_to_segment(b, from, to)) <= ACTOR_CLEARANCE:
			return false
	return true
