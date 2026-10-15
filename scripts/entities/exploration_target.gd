extends Area2D
class_name ExplorationTarget

signal selected(target: ExplorationTarget)

var target_id := ""
var target_kind := ""
var stand_position := Vector2.ZERO
var display_name := ""


func configure(id: String, kind: String, title: String, world_position: Vector2, arrival_position: Vector2, hitbox_size: Vector2) -> void:
	target_id = id
	target_kind = kind
	display_name = title
	position = world_position
	stand_position = arrival_position
	input_pickable = true
	collision_layer = 2
	collision_mask = 0
	var shape_node := CollisionShape2D.new()
	shape_node.name = "ClickTarget"
	var shape := RectangleShape2D.new()
	shape.size = hitbox_size
	shape_node.shape = shape
	add_child(shape_node)
	input_event.connect(_on_input_event)


func _on_input_event(viewport: Viewport, event: InputEvent, _shape_index: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		selected.emit(self)
		viewport.set_input_as_handled()
