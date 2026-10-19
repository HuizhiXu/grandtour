extends Control
class_name ExplorationUI

signal dialogue_choice(choice_index: int)
signal modal_closed
signal pause_requested
signal return_to_start_requested
signal licenses_requested
signal postcard_requested
signal postcard_choice(choice_index: int)
signal routes_requested
signal route_selected(index: int)
signal stop_selected(id: String)
signal next_stop_requested
signal views_requested
signal view_selected(index: int)
signal ground_view_requested

const ScreenFactory := preload("res://scripts/ui/screen_factory.gd")
const PAPER := Color("f7f0e2")
const INK := Color("30493a")
const MUTED := Color("6b745f")
const GREEN := Color("456754")
const GOLD := Color("b68b46")

var _identity: PanelContainer
var _location_label: Label
var _hint_panel: PanelContainer
var _hint_label: Label
var _npc_tag: PanelContainer
var _destination_tag: PanelContainer
var _destination_timer := 0.0
var _feedback_timer := 0.0
var _feedback_label: Label
var _modal_scrim: ColorRect
var _modal_panel: PanelContainer
var _modal_title: Label
var _modal_body: Label
var _modal_actions: VBoxContainer
var _pause_scrim: ColorRect
var _pause_panel: PanelContainer
var _paused := false
var _modal_open := false
var _quest_label: Label
var _quest_progress: Label
var _quest_panel: PanelContainer
var _quest_title: Label
var _quest_button: Button
var _route_button: Button
var _next_button: Button
var _view_button: Button
var _ground_button: Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_hud()
	_build_modal()
	_build_pause()


func _process(delta: float) -> void:
	if _feedback_timer > 0.0:
		_feedback_timer -= delta
		if _feedback_timer <= 0.0 and is_instance_valid(_feedback_label):
			_feedback_label.visible = false
	if _destination_timer > 0.0:
		_destination_timer -= delta
		if _destination_timer <= 0.0 and is_instance_valid(_destination_tag):
			_destination_tag.visible = false


func set_location(title: String) -> void:
	_location_label.text = title


func set_npc_position(world_position: Vector2, visible: bool = true) -> void:
	_npc_tag.position = world_position + Vector2(-62.0, -132.0)
	_npc_tag.visible = visible


func set_destination(world_position: Vector2) -> void:
	_destination_tag.position = Vector2(clampf(world_position.x + 16.0, 8.0, 1180.0), clampf(world_position.y + 14.0, 8.0, 688.0))
	_destination_tag.visible = true
	_destination_timer = 0.0


func clear_destination() -> void:
	_destination_tag.visible = false
	_destination_timer = 0.0


func show_feedback(text: String) -> void:
	_feedback_label.text = text
	_feedback_label.visible = true
	_feedback_timer = 2.3


func has_modal() -> bool:
	return _modal_open


func is_pointer_over_panel() -> bool:
	var pointer := get_global_mouse_position()
	return _identity.get_global_rect().has_point(pointer) or _quest_panel.get_global_rect().has_point(pointer) or pointer.x > 920.0 and pointer.y < 85.0 or _next_button.get_global_rect().has_point(pointer) or _view_button.visible and _view_button.get_global_rect().has_point(pointer)


func set_views(count: int, selected: int, panorama: bool) -> void:
	_view_button.visible = count > 1
	_view_button.text = "切换视角  %d / %d" % [selected + 1, count]
	_ground_button.visible = panorama
	_hint_label.text = "观景视角 · 点击「返回地面漫步」回到刚才的位置" if panorama else "点击空地带 Archie 漫步 · 点击人物或物件后，她会先走近再互动"


func show_views(title: String, views: Array, selected: int) -> void:
	_open_modal(title + " · 切换视角", "选一幅风景继续探索。地面视角可漫步与互动，观景视角可静静欣赏。\n各视角共享这一站的旅行记录，切回地面时记住本次游玩的位置。")
	for index in range(views.size()):
		var choice := index
		var mode := "静静观景 · 可一键返回地面" if views[index].panorama else "地面漫步 · 可观察与记录"
		var button := _make_button(str(views[index].title) + (" · 当前" if index == selected else "") + "\n" + mode, index == selected)
		button.icon = load(views[index].background) as Texture2D
		button.expand_icon = true
		button.add_theme_constant_override("icon_max_width", 144)
		button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_constant_override("h_separation", 18)
		button.custom_minimum_size.y = 100
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(func() -> void: view_selected.emit(choice))
		_modal_actions.add_child(button)
	_add_action_button("返回当前视角", close_modal, false)


func show_information(title: String, body: String) -> void:
	_open_modal(title, body)
	_add_action_button("继续漫步", func() -> void: close_modal(), true)


func show_dialogue(first_line: String) -> void:
	_open_modal("旅行摄影师", first_line)
	_add_action_button("是的，我正在探索这座城市。", func() -> void: dialogue_choice.emit(0), false)
	_add_action_button("我对这座城市的历史很感兴趣。", func() -> void: dialogue_choice.emit(1), false)
	_add_action_button("我想寄一张明信片。", func() -> void: postcard_requested.emit(), true)


func set_quest_progress(stage: int, hint: String) -> void:
	_quest_progress.text = "旅途小事  ·  %d / 4" % stage if stage < 4 else "旅途小事  ·  已完成 ✓"
	_quest_label.text = hint
	_quest_title.text = "寄出西贡的第一张明信片"
	_quest_button.text = "查看明信片"


func set_visit_progress(stage: int, hint: String) -> void:
	_quest_progress.text = "独立宫  ·  %d / 4" % stage if stage < 4 else "独立宫  ·  已完成 ✓"
	_quest_title.text = "参观独立宫"
	_quest_label.text = hint
	_quest_button.text = "查看参观纪念"


func set_stop_progress(title: String, stage: int, hint: String) -> void:
	_quest_progress.text = "景点漫步  ·  %d / 3" % stage if stage < 3 else "景点漫步  ·  已记录 ✓"
	_quest_title.text = title
	_quest_label.text = hint
	_quest_button.text = "查看旅行记录"


func set_route_progress(count: int, has_next: bool, total: int = 12) -> void:
	_route_button.text = "旅行路线  %d / %d" % [count, total]
	_next_button.text = "下一站 →" if has_next else "查看路线记录"


func show_routes(routes: Array[Dictionary], stops: Dictionary, selected_route: int, current_stop: String, completed: Dictionary) -> void:
	var route: Dictionary = routes[selected_route]
	var done := 0
	for id: String in route.stops:
		if completed.get(id, false): done += 1
	_open_modal("旅行路线册 · %d / %d 已记录" % [done, route.stops.size()], route.subtitle + "\n\n" + route.note)
	if done == route.stops.size():
		_modal_title.text = "路线已完成 · " + str(route.title)
	var tabs := HBoxContainer.new()
	_modal_actions.add_child(tabs)
	for index in range(routes.size()):
		var selected := index
		var tab_title: String = routes[index].get("tab", "西贡 · 建筑" if index == 0 else "西贡 · 文化")
		var button := _make_button(tab_title, index == selected_route)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(func() -> void: route_selected.emit(selected))
		tabs.add_child(button)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 6)
	_modal_actions.add_child(grid)
	for index in range(route.stops.size()):
		var id: String = route.stops[index]
		var suffix := "  ✓" if completed.get(id, false) else ""
		if id == current_stop: suffix += "  · 当前"
		var button := _make_button("%02d  %s%s" % [index + 1, stops[id].title, suffix], id == current_stop)
		button.custom_minimum_size = Vector2(350, 40)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(func() -> void: stop_selected.emit(id))
		grid.add_child(button)
	_add_action_button("继续漫步", close_modal, false)


func show_postcard(title: String, body: String, choices: Array[String] = []) -> void:
	_open_modal(title, body)
	for index in range(choices.size()):
		var selected := index
		_add_action_button(choices[index], func() -> void: postcard_choice.emit(selected), index == 0)
	_add_action_button("继续漫步" if choices.is_empty() else "稍后再说", close_modal, false)


func show_dialogue_reply(text: String) -> void:
	_open_modal("旅行摄影师", text)
	_add_action_button("继续漫步", func() -> void: close_modal(), true)


func close_modal() -> void:
	if not _modal_open:
		return
	_modal_open = false
	_modal_scrim.visible = false
	_modal_panel.visible = false
	modal_closed.emit()


func set_paused(paused: bool) -> void:
	_paused = paused
	_pause_scrim.visible = paused
	_pause_panel.visible = paused


func set_panel_opacity(value: float) -> void:
	var opacity := clampf(value, 0.55, 1.0)
	_identity.modulate.a = opacity
	_hint_panel.modulate.a = opacity
	_quest_panel.modulate.a = opacity


func _build_hud() -> void:
	_identity = _paper_panel(Vector2(365.0, 82.0), Vector2(26.0, 24.0))
	add_child(_identity)
	var identity_content := VBoxContainer.new()
	identity_content.add_theme_constant_override("separation", 2)
	_identity.add_child(identity_content)
	var wordmark := ScreenFactory.display_label("THE GRAND TOUR", 17, INK, "heading")
	wordmark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	identity_content.add_child(wordmark)
	_location_label = ScreenFactory.medium_label("胡志明市 · 西贡中央邮局", 14, GREEN)
	_location_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	identity_content.add_child(_location_label)

	_quest_panel = _paper_panel(Vector2(365.0, 0.0), Vector2(26.0, 118.0))
	add_child(_quest_panel)
	var quest_content := VBoxContainer.new()
	quest_content.add_theme_constant_override("separation", 7)
	_quest_panel.add_child(quest_content)
	_quest_progress = ScreenFactory.medium_label("旅途小事  ·  0 / 4", 12, GOLD)
	quest_content.add_child(_quest_progress)
	_quest_title = ScreenFactory.medium_label("寄出西贡的第一张明信片", 15, INK)
	quest_content.add_child(_quest_title)
	_quest_label = ScreenFactory.label("", 13, MUTED)
	_quest_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_quest_label.custom_minimum_size.x = 333.0
	quest_content.add_child(_quest_label)
	_ground_button = _make_button("返回地面漫步", true)
	_ground_button.visible = false
	_ground_button.pressed.connect(func() -> void: ground_view_requested.emit())
	quest_content.add_child(_ground_button)
	_quest_button = _make_button("查看明信片", false)
	_quest_button.custom_minimum_size = Vector2(0, 32)
	_quest_button.pressed.connect(func() -> void: postcard_requested.emit())
	quest_content.add_child(_quest_button)

	var pause_button := _make_button("暂停  Esc", true)
	pause_button.position = Vector2(1120.0, 26.0)
	pause_button.custom_minimum_size = Vector2(132.0, 42.0)
	pause_button.pressed.connect(func() -> void: pause_requested.emit())
	add_child(pause_button)
	_route_button = _make_button("旅行路线  0 / 12", false)
	_route_button.position = Vector2(930, 26)
	_route_button.custom_minimum_size = Vector2(176, 42)
	_route_button.pressed.connect(func() -> void: routes_requested.emit())
	add_child(_route_button)
	_view_button = _make_button("切换视角", false)
	_view_button.position = Vector2(730, 26)
	_view_button.custom_minimum_size = Vector2(184, 42)
	_view_button.visible = false
	_view_button.pressed.connect(func() -> void: views_requested.emit())
	add_child(_view_button)
	_next_button = _make_button("下一站 →", true)
	_next_button.position = Vector2(1080, 656)
	_next_button.custom_minimum_size = Vector2(172, 44)
	_next_button.pressed.connect(func() -> void: next_stop_requested.emit())
	add_child(_next_button)

	_hint_panel = _paper_panel(Vector2(500.0, 44.0), Vector2(24.0, 656.0))
	_hint_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_hint_panel)
	_hint_label = ScreenFactory.medium_label("点击空地带 Archie 漫步 · 点击人物或物件后，她会先走近再互动", 13, MUTED)
	_hint_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hint_panel.add_child(_hint_label)

	_feedback_label = ScreenFactory.medium_label("", 14, Color("fff7e7"))
	_feedback_label.position = Vector2(412.0, 22.0)
	_feedback_label.custom_minimum_size = Vector2(456.0, 30.0)
	_feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_feedback_label.visible = false
	_feedback_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_feedback_label.add_theme_stylebox_override("normal", _style(Color(GREEN, 0.92), GREEN, 10, 1))
	add_child(_feedback_label)

	_npc_tag = _paper_panel(Vector2(126.0, 31.0), Vector2.ZERO)
	_npc_tag.visible = false
	_npc_tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var npc_name := ScreenFactory.medium_label("旅行摄影师", 12, GREEN)
	npc_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	npc_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_npc_tag.add_child(npc_name)
	add_child(_npc_tag)

	_destination_tag = _paper_panel(Vector2(74.0, 29.0), Vector2.ZERO)
	_destination_tag.visible = false
	_destination_tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var destination_text := ScreenFactory.medium_label("目的地", 12, GREEN)
	destination_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	destination_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_destination_tag.add_child(destination_text)
	add_child(_destination_tag)


func _build_modal() -> void:
	_modal_scrim = ColorRect.new()
	_modal_scrim.color = Color(0.12, 0.16, 0.12, 0.14)
	_modal_scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	ScreenFactory.full_rect(_modal_scrim)
	_modal_scrim.visible = false
	_modal_scrim.gui_input.connect(_on_modal_scrim_input)
	add_child(_modal_scrim)

	_modal_panel = _paper_panel(Vector2(760.0, 0.0), Vector2.ZERO)
	_modal_panel.anchor_left = 0.5
	_modal_panel.anchor_right = 0.5
	_modal_panel.anchor_top = 1.0
	_modal_panel.anchor_bottom = 1.0
	_modal_panel.offset_left = -380.0
	_modal_panel.offset_right = 380.0
	_modal_panel.offset_top = -355.0
	_modal_panel.offset_bottom = -22.0
	_modal_panel.visible = false
	_modal_panel.z_index = 1
	_modal_panel.minimum_size_changed.connect(_fit_modal)
	add_child(_modal_panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 9)
	_modal_panel.add_child(content)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	content.add_child(header)
	_modal_title = ScreenFactory.display_label("", 19, INK, "heading")
	_modal_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_modal_title)
	var close_button := _make_button("关闭", false)
	close_button.custom_minimum_size = Vector2(74.0, 34.0)
	close_button.pressed.connect(close_modal)
	header.add_child(close_button)
	_modal_body = ScreenFactory.label("", 15, INK)
	_modal_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_modal_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Give wrapping a real width even when this is the first modal after loading.
	_modal_body.custom_minimum_size = Vector2(728.0, 30.0)
	content.add_child(_modal_body)
	_modal_actions = VBoxContainer.new()
	_modal_actions.add_theme_constant_override("separation", 6)
	content.add_child(_modal_actions)


func _build_pause() -> void:
	_pause_scrim = ColorRect.new()
	_pause_scrim.color = Color(0.08, 0.12, 0.09, 0.38)
	_pause_scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	ScreenFactory.full_rect(_pause_scrim)
	_pause_scrim.visible = false
	add_child(_pause_scrim)

	_pause_panel = _paper_panel(Vector2(420.0, 250.0), Vector2.ZERO)
	_pause_panel.set_anchors_preset(Control.PRESET_CENTER)
	_pause_panel.position = Vector2(-210.0, -125.0)
	_pause_panel.visible = false
	_pause_panel.z_index = 1
	add_child(_pause_panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	_pause_panel.add_child(content)
	var heading := ScreenFactory.display_label("漫步暂停", 25, INK, "heading")
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(heading)
	var resume := _make_button("继续漫步", true)
	resume.pressed.connect(func() -> void: pause_requested.emit())
	content.add_child(resume)
	var reset := _make_button("回到街区入口", false)
	reset.pressed.connect(func() -> void: return_to_start_requested.emit())
	content.add_child(reset)
	var licenses := _make_button("开源软件声明", false)
	licenses.pressed.connect(func() -> void: licenses_requested.emit())
	content.add_child(licenses)


func _open_modal(title: String, body: String) -> void:
	_modal_open = true
	_modal_title.text = title
	_modal_body.text = body
	for child in _modal_actions.get_children():
		_modal_actions.remove_child(child)
		child.queue_free()
	_modal_scrim.visible = true
	_modal_panel.visible = true
	_fit_modal.call_deferred()


func _fit_modal() -> void:
	var height := maxf(180.0, _modal_panel.get_combined_minimum_size().y)
	_modal_panel.offset_top = -22.0 - height
	_modal_panel.offset_bottom = -22.0


func _add_action_button(text: String, action: Callable, primary: bool) -> void:
	var button := _make_button(text, primary)
	button.custom_minimum_size.y = 42.0
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(action)
	_modal_actions.add_child(button)


func _paper_panel(size: Vector2, at: Vector2) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.position = at
	panel.custom_minimum_size = size
	panel.add_theme_stylebox_override("panel", _style(Color(PAPER, 0.96), Color(GREEN, 0.76), 14, 1))
	return panel


func _style(background: Color, border: Color, radius: int, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
	style.content_margin_top = 9.0
	style.content_margin_bottom = 9.0
	style.shadow_color = Color(0.13, 0.16, 0.12, 0.18)
	style.shadow_size = 5
	style.shadow_offset = Vector2(0.0, 2.0)
	return style


func _make_button(text: String, primary: bool) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_ALL
	button.custom_minimum_size = Vector2(250.0, 44.0)
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_color_override("font_color", PAPER if primary else INK)
	button.add_theme_color_override("font_hover_color", PAPER if primary else GREEN)
	button.add_theme_color_override("font_pressed_color", PAPER)
	button.add_theme_stylebox_override("normal", _style(GREEN if primary else Color("f3ead7"), GREEN if primary else Color("d6cbb5"), 9, 1))
	button.add_theme_stylebox_override("hover", _style(Color("587763") if primary else Color("eee4d0"), GOLD, 9, 1))
	button.add_theme_stylebox_override("pressed", _style(Color("3d5c49"), GOLD, 9, 1))
	button.add_theme_stylebox_override("focus", _style(Color.TRANSPARENT, GOLD, 9, 2))
	return button


func _on_modal_scrim_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		close_modal()
		accept_event()
