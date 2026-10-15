extends CharacterBody2D
class_name Traveler

signal route_completed
signal route_blocked

const SPRITE_ATLAS: Texture2D = preload("res://assets/game/runtime/traveler-atlas.png")
const FRAME_SIZE := Vector2(128.0, 160.0)
const SPRITE_SCALE := 0.58
const WALK_ANIMATIONS := ["walk_down", "walk_left", "walk_up", "walk_right"]
const IDLE_ANIMATIONS := ["idle_down", "idle_left", "idle_up", "idle_right"]

@export var walk_speed := 190.0

var _frames: AnimatedSprite2D
var _path := PackedVector2Array()
var _path_index := 0
var _facing_row := 0
var _stalled_frames := 0


func _ready() -> void:
	collision_layer = 1
	collision_mask = 1
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	safe_margin = 0.1
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_frames = AnimatedSprite2D.new()
	_frames.name = "TravelerFrames"
	_frames.centered = false
	_frames.position = Vector2(-FRAME_SIZE.x * SPRITE_SCALE * 0.5, -FRAME_SIZE.y * SPRITE_SCALE)
	_frames.scale = Vector2.ONE * SPRITE_SCALE
	_frames.sprite_frames = _make_sprite_frames()
	add_child(_frames)
	var hitbox := CollisionShape2D.new()
	hitbox.name = "Footprint"
	var shape := CapsuleShape2D.new()
	shape.radius = 9.0
	shape.height = 24.0
	hitbox.shape = shape
	hitbox.position = Vector2(0.0, -9.0)
	add_child(hitbox)
	_frames.play(IDLE_ANIMATIONS[_facing_row])


func set_walk_speed(speed: float) -> void:
	walk_speed = clampf(speed, 90.0, 280.0)


func set_path(points: PackedVector2Array) -> void:
	_path = points.duplicate()
	_path_index = 0
	_stalled_frames = 0
	while _path_index < _path.size() and global_position.distance_to(_path[_path_index]) < 4.0:
		_path_index += 1
	if _path_index >= _path.size():
		_path.clear()
		velocity = Vector2.ZERO
		_play_idle()
		route_completed.emit()
		return
	_play_walk(_path[_path_index] - global_position)


func cancel_path() -> void:
	_path.clear()
	_path_index = 0
	_stalled_frames = 0
	velocity = Vector2.ZERO
	_play_idle()


func is_walking() -> bool:
	return _path_index < _path.size()


func current_destination() -> Vector2:
	if not _path.is_empty():
		return _path[_path.size() - 1]
	return global_position


func _physics_process(delta: float) -> void:
	if not is_walking():
		return
	var target := _path[_path_index]
	var direction := global_position.direction_to(target)
	if direction == Vector2.ZERO:
		_path_index += 1
		if _path_index >= _path.size():
			_finish_route()
		return
	_play_walk(direction)
	velocity = direction * walk_speed
	var before := global_position
	move_and_slide()
	if before.distance_squared_to(global_position) < 0.04:
		_stalled_frames += 1
	else:
		_stalled_frames = 0
	if _stalled_frames >= 20:
		cancel_path()
		route_blocked.emit()
		return
	if global_position.distance_to(target) <= maxf(3.5, walk_speed * delta * 0.65):
		global_position = target
		_path_index += 1
		if _path_index >= _path.size():
			_finish_route()
		else:
			_play_walk(_path[_path_index] - global_position)


func _finish_route() -> void:
	_path.clear()
	_path_index = 0
	velocity = Vector2.ZERO
	_stalled_frames = 0
	_play_idle()
	route_completed.emit()


func _play_walk(direction: Vector2) -> void:
	_facing_row = _direction_row(direction)
	var animation: StringName = WALK_ANIMATIONS[_facing_row]
	if _frames.animation != animation:
		_frames.play(animation)


func _play_idle() -> void:
	var animation: StringName = IDLE_ANIMATIONS[_facing_row]
	if _frames.animation != animation:
		_frames.play(animation)
	_frames.pause()


func _direction_row(direction: Vector2) -> int:
	if absf(direction.x) > absf(direction.y):
		return 3 if direction.x > 0.0 else 1
	return 0 if direction.y > 0.0 else 2


func _make_sprite_frames() -> SpriteFrames:
	var result := SpriteFrames.new()
	for row in range(4):
		var idle_name: StringName = IDLE_ANIMATIONS[row]
		var walk_name: StringName = WALK_ANIMATIONS[row]
		result.add_animation(idle_name)
		result.set_animation_speed(idle_name, 1.0)
		result.set_animation_loop(idle_name, false)
		result.add_frame(idle_name, _atlas_frame(0, row))
		result.add_animation(walk_name)
		result.set_animation_speed(walk_name, 9.0)
		result.set_animation_loop(walk_name, true)
		for column in range(4):
			result.add_frame(walk_name, _atlas_frame(column, row), 1.0)
	return result


func _atlas_frame(column: int, row: int) -> AtlasTexture:
	var frame := AtlasTexture.new()
	frame.atlas = SPRITE_ATLAS
	frame.region = Rect2(Vector2(column, row) * FRAME_SIZE, FRAME_SIZE)
	return frame
