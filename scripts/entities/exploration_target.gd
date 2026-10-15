extends Area2D
class_name ExplorationTarget

signal selected(target: ExplorationTarget)

var target_id := ""
var target_kind := ""
var stand_position := Vector2.ZERO
var display_name := ""
var _label: Label
var _label_always_visible := false


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
	_label = Label.new()
	_label.text = title
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.position = Vector2(-100, -hitbox_size.y * 0.5 - 32)
	_label.size = Vector2(200, 28)
	_label.add_theme_font_size_override("font_size", 14)
	_label.add_theme_color_override("font_color", Color("fff7e7"))
	_label.add_theme_color_override("font_outline_color", Color("30493a"))
	_label.add_theme_constant_override("outline_size", 6)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label_always_visible = id == "postcard_desk" or id.begins_with("palace_") or id == "post_office_return"
	_label.visible = _label_always_visible
	if _label_always_visible:
		_label.mouse_filter = Control.MOUSE_FILTER_STOP
		_label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_label.gui_input.connect(func(event: InputEvent) -> void:
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				selected.emit(self)
				_label.accept_event()
		)
	add_child(_label)


func set_highlighted(value: bool) -> void:
	_label.visible = value or _label_always_visible


func _on_input_event(viewport: Viewport, event: InputEvent, _shape_index: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		selected.emit(self)
		viewport.set_input_as_handled()
