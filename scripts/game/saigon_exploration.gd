extends Node2D

const Pathfinder := preload("res://scripts/game/iso_pathfinder.gd")
const TravelerType := preload("res://scripts/entities/traveler.gd")
const TargetType := preload("res://scripts/entities/exploration_target.gd")
const UIType := preload("res://scripts/ui/exploration_ui.gd")
const OpenSourceLicenseHelper := preload("res://scripts/manus/open_source_licenses.gd")
const Postcard := preload("res://scripts/game/postcard_quest.gd")
const Palace := preload("res://scripts/game/palace_visit.gd")
const TourCatalog := preload("res://scripts/game/tour_catalog.gd")
const TourProgress := preload("res://scripts/game/tour_progress.gd")
const TourWorld := preload("res://scripts/game/tour_world.gd")
const PALACE_BG: Texture2D = preload("res://assets/game/runtime/independence-palace.jpg")
const PALACE_HALL_BG: Texture2D = preload("res://assets/game/runtime/independence-palace-hall.jpg")
const OUTDOOR_BG: Texture2D = preload("res://assets/game/runtime/saigon-exterior.jpg")
const INDOOR_BG: Texture2D = preload("res://assets/game/runtime/post-office-interior.jpg")
const SIGN_TEXTURE: Texture2D = preload("res://assets/game/runtime/intro-sign.png")
const MAILBOX_TEXTURE: Texture2D = preload("res://assets/game/runtime/old-mailbox.png")
const PHOTOGRAPHER_TEXTURE: Texture2D = preload("res://assets/game/runtime/photographer-npc.png")
const WORLD_SIZE := Vector2(1280.0, 720.0)

const SIGN_BODY := "西贡中央邮局是胡志明市最具代表性的历史建筑之一，以其宏伟的空间和法国殖民时期的建筑风格闻名。"
const MAILBOX_BODY := "这个旧邮筒似乎已经在这里很久了。不知道它曾经寄出过多少封信。"
const PHOTOGRAPHER_REPLIES := [
	"那你一定要看看这座邮局。这里有很多值得发现的建筑细节。",
	"那你来对地方了。西贡的每一条街道，似乎都有自己的故事。",
]

var _background_root: Node2D
var _collision_root: Node2D
var _sortable_world: Node2D
var _ui_layer: CanvasLayer
var _ui: ExplorationUI
var _traveler: Traveler
var _photographer: Sprite2D
var _pathfinder: IsoPathfinder
var _targets: Dictionary = {}
var _pending_target: ExplorationTarget
var _scene_id := "outdoor"
var _transitioning := false
var _paused := false
var _fade: ColorRect
var _postcard := Postcard.new()
var _postcard_context := ""
var _destination_marker: Line2D
var _hovered_target: ExplorationTarget
var _palace := Palace.new()
var _tour := TourProgress.new()
var _route_index := 0
var _view_index := 0
var _panorama := false
var _view_positions: Dictionary = {}
var _ground_views: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var save_store := get_node_or_null("/root/SaveStore")
	if save_store != null:
		_postcard.restore(save_store.call("get_postcard_progress"))
		_palace.restore(save_store.call("get_palace_progress"))
		_tour.restore(save_store.call("get_tour_progress"))
	var locale_service := get_node_or_null("/root/I18n")
	if locale_service != null:
		locale_service.call("set_locale", "zh-CN")
	_build_world_layers()
	_build_ui()
	_build_traveler()
	_setup_scene("outdoor", Vector2(640.0, 622.0))
	var tuning_store := get_node_or_null("/root/TuningStore")
	if tuning_store != null:
		tuning_store.connect("value_changed", _on_tuning_changed)
	_apply_tuning()
	_update_postcard_hud()


func _process(_delta: float) -> void:
	var hovered: ExplorationTarget
	if not _paused and not _transitioning and not _ui.has_modal() and not _ui.is_pointer_over_panel():
		hovered = _target_at(get_global_mouse_position())
	if hovered == _hovered_target:
		return
	if is_instance_valid(_hovered_target):
		_hovered_target.set_highlighted(false)
	_hovered_target = hovered
	if is_instance_valid(_hovered_target):
		_hovered_target.set_highlighted(true)
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND if hovered != null else Input.CURSOR_ARROW)


func _unhandled_input(event: InputEvent) -> void:
	if _transitioning:
		return
	if event.is_action_pressed("pause"):
		if _ui.has_modal():
			_ui.close_modal()
		elif _paused:
			_set_paused(false)
		else:
			_set_paused(true)
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if _paused or _ui.has_modal() or _transitioning:
			return
		var destination := get_global_mouse_position()
		var clicked_target := _target_at(destination)
		if clicked_target != null:
			_on_target_selected(clicked_target)
		else:
			_pending_target = null
			_request_walk(destination)
		get_viewport().set_input_as_handled()


func _target_at(world_position: Vector2) -> ExplorationTarget:
	var query := PhysicsPointQueryParameters2D.new()
	query.position = world_position
	query.collision_mask = 2
	query.collide_with_areas = true
	query.collide_with_bodies = false
	for hit in get_world_2d().direct_space_state.intersect_point(query, 16):
		var target := hit.get("collider") as ExplorationTarget
		if target != null:
			return target
	return null


func _build_world_layers() -> void:
	var letterbox_layer := CanvasLayer.new()
	letterbox_layer.name = "WarmLetterbox"
	letterbox_layer.layer = -10
	add_child(letterbox_layer)
	var warm_canvas := ColorRect.new()
	warm_canvas.name = "PaperCanvasFill"
	warm_canvas.color = Color("f7f2e7")
	warm_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	warm_canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	letterbox_layer.add_child(warm_canvas)
	_background_root = Node2D.new()
	_background_root.name = "PaintedWorld"
	add_child(_background_root)
	_collision_root = Node2D.new()
	_collision_root.name = "WorldColliders"
	add_child(_collision_root)
	_sortable_world = Node2D.new()
	_sortable_world.name = "ActorsAndClickableProps"
	_sortable_world.y_sort_enabled = true
	add_child(_sortable_world)
	_ui_layer = CanvasLayer.new()
	_ui_layer.layer = 10
	add_child(_ui_layer)
	_fade = ColorRect.new()
	_fade.name = "SceneTransition"
	_fade.color = Color(0.11, 0.16, 0.12, 0.0)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.z_index = 80
	_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ui_layer.add_child(_fade)


func _build_ui() -> void:
	_ui = UIType.new()
	_ui_layer.add_child(_ui)
	_ui.pause_requested.connect(_toggle_pause)
	_ui.return_to_start_requested.connect(_return_to_start)
	_ui.licenses_requested.connect(_open_licenses)
	_ui.dialogue_choice.connect(_on_dialogue_choice)
	_ui.postcard_requested.connect(_show_current_journey)
	_ui.postcard_choice.connect(_on_postcard_choice)
	_ui.routes_requested.connect(_show_routes)
	_ui.route_selected.connect(func(index: int) -> void:
		_route_index = index
		_show_routes()
	)
	_ui.stop_selected.connect(_travel_to_stop)
	_ui.next_stop_requested.connect(_travel_next)
	_ui.views_requested.connect(_show_views)
	_ui.view_selected.connect(_select_view)
	_ui.ground_view_requested.connect(_return_to_ground)
	_ui.modal_closed.connect(func() -> void: _postcard_context = "")


func _build_traveler() -> void:
	_traveler = TravelerType.new()
	_traveler.name = "Traveler"
	_traveler.route_completed.connect(_on_traveler_arrived)
	_traveler.route_blocked.connect(_on_traveler_blocked)
	_sortable_world.add_child(_traveler)
	var shadow := Polygon2D.new()
	shadow.name = "FootShadow"
	shadow.color = Color(0.20, 0.18, 0.12, 0.19)
	shadow.polygon = PackedVector2Array([Vector2(-15, 1), Vector2(-11, -4), Vector2(11, -4), Vector2(15, 1), Vector2(10, 5), Vector2(-10, 5)])
	shadow.z_index = -1
	_traveler.add_child(shadow)


func _setup_scene(scene_name: String, player_spawn: Vector2, view_index: int = 0) -> void:
	_scene_id = scene_name
	_view_index = view_index
	_panorama = TourWorld.layout(scene_name, view_index).get("panorama", false) if TourCatalog.is_new_stop(scene_name) else false
	_traveler.visible = not _panorama
	_hovered_target = null
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	_pending_target = null
	_traveler.cancel_path()
	_traveler.global_position = player_spawn
	for child in _background_root.get_children():
		child.free()
	for child in _collision_root.get_children():
		child.free()
	for child in _sortable_world.get_children():
		if child != _traveler:
			child.free()
	_targets.clear()
	_photographer = null

	var background := Sprite2D.new()
	background.name = "SceneIllustration"
	if TourCatalog.is_new_stop(scene_name):
		background.texture = load(TourCatalog.background_path(scene_name, _view_index)) as Texture2D
	else:
		background.texture = {"outdoor": OUTDOOR_BG, "indoor": INDOOR_BG, "palace_garden": PALACE_BG, "palace_hall": PALACE_HALL_BG}[scene_name]
	background.position = WORLD_SIZE * 0.5
	background.scale = WORLD_SIZE / Vector2(background.texture.get_size())
	background.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_background_root.add_child(background)
	_destination_marker = Line2D.new()
	_destination_marker.name = "DestinationFootprint"
	_destination_marker.points = PackedVector2Array([Vector2(0, -6), Vector2(13, 0), Vector2(0, 6), Vector2(-13, 0), Vector2(0, -6)])
	_destination_marker.width = 2.0
	_destination_marker.default_color = Color("456754")
	_destination_marker.antialiased = true
	_destination_marker.visible = false
	_background_root.add_child(_destination_marker)

	var walk_rect: Rect2
	var obstacles: Array[Rect2]
	var walls: Array[PackedVector2Array]
	var floor_outline: PackedVector2Array
	if TourCatalog.is_new_stop(scene_name):
		walk_rect = Rect2(70, 370, 1140, 338)
		floor_outline = _tour_floor(scene_name)
		obstacles.assign(TourWorld.layout(scene_name, _view_index).obstacles)
		if _panorama: walk_rect = Rect2()
		var region := "暹粒" if scene_name.begins_with("angkor_") else "西贡"
		_ui.set_location("%s · %s" % [region, TourCatalog.STOPS[scene_name].title])
		if not TourCatalog.views(scene_name).is_empty():
			_ui.set_location("%s · %s" % [TourCatalog.STOPS[scene_name].title, TourCatalog.views(scene_name)[_view_index].title])
	elif scene_name == "outdoor":
		walk_rect = Rect2(Vector2(18.0, 230.0), Vector2(1244.0, 478.0))
		obstacles = _outdoor_obstacles()
		walls = _outdoor_walls()
		floor_outline = _outdoor_floor()
		_ui.set_location("胡志明市 · 西贡中央邮局")
	elif scene_name == "indoor":
		walk_rect = Rect2(Vector2(72.0, 158.0), Vector2(1136.0, 535.0))
		obstacles = _indoor_obstacles()
		walls = _indoor_walls()
		floor_outline = _indoor_floor()
		_ui.set_location("西贡中央邮局 · 内部大厅")
	else:
		walk_rect = Rect2(60, 260, 1160, 448)
		floor_outline = _palace_floor(scene_name)
		walls = _palace_walls(scene_name)
		_ui.set_location("路线 1 · 独立宫 · " + ("庭院" if scene_name == "palace_garden" else "参观大厅"))
	_pathfinder = Pathfinder.new()
	_pathfinder.configure(walk_rect, obstacles, walls, floor_outline)
	if not _panorama: _add_floor_boundary(floor_outline)
	for index in range(obstacles.size()):
		_add_physical_obstacle(obstacles[index], index)
	for index in range(walls.size()):
		var body := StaticBody2D.new()
		body.name = "WallSurface_%02d" % index
		body.collision_layer = 1
		body.collision_mask = 1
		var collision := CollisionPolygon2D.new()
		collision.polygon = walls[index]
		body.add_child(collision)
		_collision_root.add_child(body)

	if TourCatalog.is_new_stop(scene_name):
		if not _panorama: _build_tour_targets(scene_name)
		_ui.set_npc_position(Vector2.ZERO, false)
	elif scene_name == "outdoor":
		_build_outdoor_targets()
		_ui.set_npc_position(Vector2(938.0, 528.0), true)
	elif scene_name == "indoor":
		_add_target("outdoor_exit", "exit", "返回广场", Vector2(640.0, 674.0), Vector2(640.0, 575.0), Vector2(164.0, 98.0))
		_add_target("postcard_desk", "postcard", "明信片书写台", Vector2(828.0, 366.0), Vector2(770.0, 460.0), Vector2(116.0, 90.0))
		_ui.set_npc_position(Vector2.ZERO, false)
	else:
		_build_palace_targets(scene_name)
		_ui.set_npc_position(Vector2.ZERO, false)
	_ui.clear_destination()
	_ui.set_paused(false)
	_update_postcard_hud()


func _tour_floor(id: String) -> PackedVector2Array:
	return TourWorld.layout(id, _view_index).floor


func _build_tour_targets(id: String) -> void:
	var stop: Dictionary = TourCatalog.STOPS[id]
	var layout: Dictionary = TourWorld.layout(id, _view_index)
	_add_target("tour_info", "tour_info", "景点介绍", layout.info, layout.info_stand, Vector2(100, 100))
	_add_target("tour_activity", "tour_activity", stop.object, layout.activity, layout.activity_stand, Vector2(130, 104))
	_add_target("tour_record", "tour_record", "记录这一站", layout.get("record", Vector2(640, 690)), layout.get("record_stand", Vector2(640, 615)), Vector2(150, 44))
	if not TourCatalog.views(id).is_empty():
		# Keep the record label above the bottom hint panel and away from Archie.
		var label := (_targets["tour_record"] as ExplorationTarget).get("_label") as Label
		label.global_position = Vector2(530, 600)
		if id == "angkor_ta_prohm" and _view_index == 2:
			var activity_label := (_targets["tour_activity"] as ExplorationTarget).get("_label") as Label
			activity_label.global_position = Vector2(350, 540)


func _completed_stops() -> Dictionary:
	var completed := {"palace": _palace.stage() == 4, "post_office": _postcard.sent}
	for id: String in TourCatalog.STOPS:
		if TourCatalog.is_new_stop(id): completed[id] = _tour.stage(id) == 3
	return completed


func _show_routes() -> void:
	if _paused or _transitioning: return
	_traveler.cancel_path()
	_pending_target = null
	_clear_destination()
	_postcard_context = "routes"
	_ui.show_routes(TourCatalog.ROUTES, TourCatalog.STOPS, _route_index, TourCatalog.stop_for_scene(_scene_id), _completed_stops())


func _show_views() -> void:
	if _paused or _transitioning or TourCatalog.views(_scene_id).is_empty(): return
	_traveler.cancel_path()
	_pending_target = null
	_clear_destination()
	var perspectives := TourCatalog.views(_scene_id).duplicate(true)
	for index in range(perspectives.size()):
		perspectives[index]["background"] = TourCatalog.background_path(_scene_id, index)
		perspectives[index]["panorama"] = TourWorld.layout(_scene_id, index).get("panorama", false)
	_ui.show_views(TourCatalog.STOPS[_scene_id].title, perspectives, _view_index)


func _select_view(index: int) -> void:
	if _paused or _transitioning or index < 0 or index >= TourCatalog.views(_scene_id).size(): return
	_ui.close_modal()
	if index != _view_index: await _transition_to(_scene_id, index)


func _return_to_ground() -> void:
	if not _panorama or _paused or _transitioning: return
	await _select_view(int(_ground_views.get(_scene_id, 0)))


func _travel_to_stop(id: String) -> void:
	if _paused or _transitioning or not TourCatalog.STOPS.has(id): return
	_route_index = TourCatalog.route_for_stop(id)
	_ui.close_modal()
	var scene: String = TourCatalog.STOPS[id].scene
	if scene == _scene_id and _view_index == 0: return
	var from_stop := TourCatalog.stop_for_scene(_scene_id)
	await _transition_to(scene)
	var by_car := id == "pink_church" or from_stop == "pink_church"
	_ui.show_feedback(("乘车转场 · " if by_car else "沿路线前往 · ") + str(TourCatalog.STOPS[id].title))


func _next_stop_id() -> String:
	var current := TourCatalog.stop_for_scene(_scene_id)
	var route: Dictionary = TourCatalog.ROUTES[TourCatalog.route_for_stop(current)]
	var index: int = route.stops.find(current)
	return str(route.stops[index + 1]) if index >= 0 and index + 1 < route.stops.size() else ""


func _travel_next() -> void:
	if _paused or _transitioning: return
	var id := _next_stop_id()
	if id.is_empty():
		_route_index = TourCatalog.route_for_stop(TourCatalog.stop_for_scene(_scene_id))
		_show_routes()
	else:
		_travel_to_stop(id)


func _tour_hint() -> String:
	if _panorama: return "静静欣赏眼前的风景。点击「返回地面漫步」，可继续探索与记录。"
	var entry: Dictionary = _tour.state(_scene_id)
	if not entry.read: return "走近「景点介绍」，了解这一站的故事。"
	if entry.choice < 0: return "走到「%s」，%s。" % [TourCatalog.STOPS[_scene_id].object, TourCatalog.STOPS[_scene_id].activity]
	if not entry.recorded: return "走到前方「记录这一站」，留下你的旅行印象。"
	return "这一站已记录。继续漫步，或点击「下一站」前往新的景点。"


func _save_tour() -> void:
	_update_postcard_hud()
	var store := get_node_or_null("/root/SaveStore")
	if store != null and not store.call("set_tour_progress", _tour.serialize()):
		_ui.show_feedback("暂时无法保存；本次旅行仍可继续。")


func _show_tour_activity() -> void:
	var stop: Dictionary = TourCatalog.STOPS[_scene_id]
	if _tour.stage(_scene_id) == 3:
		_show_tour_record()
		return
	_postcard_context = "tour_choice"
	var choices: Array[String] = []
	choices.assign(stop.choices)
	_ui.show_postcard(stop.activity, stop.prompt, choices)


func _show_tour_record() -> void:
	if _paused or _transitioning: return
	_traveler.cancel_path()
	_pending_target = null
	_clear_destination()
	var stop: Dictionary = TourCatalog.STOPS[_scene_id]
	var entry: Dictionary = _tour.state(_scene_id)
	_postcard_context = "tour_status"
	if entry.recorded:
		_ui.show_postcard(stop.title + " · 旅行记录", "这一站已记录 ✓\n\n%s\n\n%s" % [stop.choices[entry.choice], stop.replies[entry.choice]])
	elif _tour.stage(_scene_id) == 2 and _near_target("tour_record"):
		_postcard_context = "tour_record"
		_ui.show_postcard("留下这一站的印象", "%s\n\n%s" % [stop.title, stop.replies[entry.choice]], ["记入旅行手记"])
	else:
		_ui.show_postcard(stop.title + " · 旅行记录", _tour_hint())


func _palace_floor(scene_name: String) -> PackedVector2Array:
	if scene_name == "palace_hall":
		return PackedVector2Array([Vector2(410, 286), Vector2(866, 286), Vector2(1020, 370), Vector2(1130, 540), Vector2(1080, 700), Vector2(190, 700), Vector2(150, 540), Vector2(300, 370)])
	# Paving follows the facade, side planting beds and foreground tree line.
	return PackedVector2Array([Vector2(140, 326), Vector2(560, 326), Vector2(560, 310), Vector2(720, 310), Vector2(720, 326), Vector2(1140, 326), Vector2(1090, 410), Vector2(1190, 520), Vector2(1060, 608), Vector2(1010, 700), Vector2(265, 700), Vector2(230, 612), Vector2(85, 566), Vector2(110, 494), Vector2(225, 416)])


func _palace_walls(scene_name: String) -> Array[PackedVector2Array]:
	if scene_name == "palace_hall":
		return []
	# The ellipse is a real collision polygon shared with navigation, not a
	# rectangular proxy that blocks the narrow rear walkway.
	var lawn := PackedVector2Array()
	for index in range(32):
		var angle := TAU * float(index) / 32.0
		lawn.append(Vector2(645, 478) + Vector2(cos(angle) * 337.0, sin(angle) * 83.0))
	return [lawn]


func _build_palace_targets(scene_name: String) -> void:
	if scene_name == "palace_garden":
		_add_target("palace_architecture", "palace_architecture", "建筑介绍", Vector2(1115, 550), Vector2(1040, 580), Vector2(80, 74))
		_add_target("palace_view", "palace_view", "庭院观景", Vector2(177, 590), Vector2(275, 600), Vector2(74, 74))
		_add_target("palace_door", "palace_enter", "进入独立宫", Vector2(640, 320), Vector2(640, 352), Vector2(130, 82))
		_add_target("post_office_return", "post_office_return", "返回中央邮局", Vector2(640, 674), Vector2(640, 640), Vector2(160, 62))
	else:
		_add_target("palace_exhibit", "palace_exhibit", "接待厅展览说明", Vector2(640, 253), Vector2(640, 322), Vector2(150, 70))
		_add_target("palace_souvenir", "palace_souvenir", "参观纪念台", Vector2(1110, 355), Vector2(990, 430), Vector2(120, 100))
		_add_target("palace_exit", "palace_exit", "返回庭院", Vector2(640, 680), Vector2(640, 630), Vector2(170, 70))


func _outdoor_floor() -> PackedVector2Array:
	# Public paving only: follow the FRONT of fences and pillars, not the facade.
	# The concave central notch is the one open route to the porch.
	return PackedVector2Array([
		Vector2(142, 440), Vector2(246, 412), Vector2(430, 402),
		Vector2(492, 389), Vector2(548, 380), Vector2(560, 366),
		Vector2(650, 382), Vector2(678, 404), Vector2(690, 442),
		Vector2(756, 466), Vector2(850, 498), Vector2(942, 528),
		Vector2(1044, 559), Vector2(1128, 586), Vector2(1128, 676),
		Vector2(1030, 704), Vector2(258, 704), Vector2(258, 606),
		Vector2(220, 550), Vector2(164, 510),
	])


func _indoor_floor() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(376, 322), Vector2(576, 322), Vector2(1130, 540),
		Vector2(1120, 592), Vector2(892, 652), Vector2(738, 652),
		Vector2(738, 706), Vector2(542, 706), Vector2(542, 652),
		Vector2(280, 652), Vector2(130, 574), Vector2(100, 544),
	])


func _add_floor_boundary(outline: PackedVector2Array) -> void:
	var body := StaticBody2D.new()
	body.name = "WalkableGroundBoundary"
	body.collision_layer = 1
	body.collision_mask = 1
	var boundary := CollisionPolygon2D.new()
	boundary.name = "SharedFloorOutline"
	boundary.build_mode = CollisionPolygon2D.BUILD_SEGMENTS
	boundary.polygon = outline
	body.add_child(boundary)
	_collision_root.add_child(body)


func _outdoor_obstacles() -> Array[Rect2]:
	return [
		Rect2(Vector2(26.0, 330.0), Vector2(108.0, 180.0)),
		Rect2(Vector2(0.0, 520.0), Vector2(245.0, 200.0)),
		Rect2(Vector2(1150.0, 320.0), Vector2(130.0, 218.0)),
		Rect2(Vector2(1024.0, 542.0), Vector2(132.0, 106.0)),
		Rect2(Vector2(270.0, 344.0), Vector2(72.0, 38.0)),
		Rect2(Vector2(948.0, 375.0), Vector2(74.0, 38.0)),
		Rect2(Vector2(752.0, 360.0), Vector2(30.0, 22.0)),
		Rect2(Vector2(322.0, 510.0), Vector2(24.0, 18.0)),
		Rect2(Vector2(924.0, 512.0), Vector2(28.0, 18.0)),
		Rect2(Vector2(269.0, 518.0), Vector2(24.0, 14.0)),
		Rect2(Vector2(334.0, 610.0), Vector2(34.0, 24.0)),
	]


func _outdoor_walls() -> Array[PackedVector2Array]:
	# Follow the painted facade's ground line, leaving the central porch open.
	return [
		PackedVector2Array([Vector2(0, 0), Vector2(552, 0), Vector2(552, 354), Vector2(140, 280), Vector2(0, 280)]),
		PackedVector2Array([Vector2(664, 0), Vector2(1280, 0), Vector2(1280, 460), Vector2(664, 382)]),
		PackedVector2Array([Vector2(552, 0), Vector2(664, 0), Vector2(664, 285), Vector2(552, 285)]),
	]


func _indoor_walls() -> Array[PackedVector2Array]:
	# Side walls converge at the back of the hall; the foreground gate stays open.
	return [
		PackedVector2Array([Vector2(0, 0), Vector2(376, 0), Vector2(376, 304), Vector2(72, 548), Vector2(0, 548)]),
		PackedVector2Array([Vector2(376, 0), Vector2(576, 0), Vector2(576, 304), Vector2(376, 304)]),
		PackedVector2Array([Vector2(576, 0), Vector2(1280, 0), Vector2(1280, 548), Vector2(576, 304)]),
	]


func _indoor_obstacles() -> Array[Rect2]:
	return [
		Rect2(Vector2(0.0, 648.0), Vector2(542.0, 72.0)),
		Rect2(Vector2(738.0, 648.0), Vector2(542.0, 72.0)),
		Rect2(Vector2(172.0, 306.0), Vector2(280.0, 144.0)),
		Rect2(Vector2(828.0, 306.0), Vector2(280.0, 144.0)),
		Rect2(Vector2(222.0, 486.0), Vector2(188.0, 60.0)),
		Rect2(Vector2(870.0, 486.0), Vector2(188.0, 60.0)),
	]


func _add_physical_obstacle(rect: Rect2, index: int) -> void:
	var body := StaticBody2D.new()
	body.name = "BlockedSurface_%02d" % index
	body.collision_layer = 1
	body.collision_mask = 1
	body.position = rect.position + rect.size * 0.5
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collision.shape = shape
	body.add_child(collision)
	_collision_root.add_child(body)


func _build_outdoor_targets() -> void:
	_add_target("post_office_info", "info", "建筑介绍牌", Vector2(766.0, 378.0), Vector2(800.0, 530.0), Vector2(108.0, 128.0), SIGN_TEXTURE)
	_add_target("old_mailbox", "mailbox", "旧邮筒", Vector2(334.0, 524.0), Vector2(400.0, 542.0), Vector2(86.0, 114.0), MAILBOX_TEXTURE)
	_add_target("photographer", "npc", "旅行摄影师", Vector2(938.0, 528.0), Vector2(862.0, 540.0), Vector2(92.0, 126.0), PHOTOGRAPHER_TEXTURE)
	_add_target("post_office_door", "enter", "进入邮局", Vector2(608.0, 330.0), Vector2(608.0, 416.0), Vector2(100.0, 96.0))
	_add_target("palace_travel", "palace_travel", "前往独立宫 →", Vector2(966, 664), Vector2(938, 620), Vector2(175, 64))


func _add_target(id: String, kind: String, title: String, world_position: Vector2, stand: Vector2, hitbox: Vector2, texture: Texture2D = null) -> ExplorationTarget:
	var target := TargetType.new()
	target.name = "Target_" + id
	target.configure(id, kind, title, world_position, stand, hitbox)
	target.selected.connect(_on_target_selected)
	var target_sprite: Sprite2D
	if texture != null:
		target_sprite = Sprite2D.new()
		target_sprite.texture = texture
		target_sprite.centered = false
		var sprite_scale := 0.58 if id == "photographer" else 0.68
		target_sprite.position = Vector2(-64.0 * sprite_scale, -160.0 * sprite_scale)
		target_sprite.scale = Vector2.ONE * sprite_scale
		target_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		target.add_child(target_sprite)
	if id == "photographer" and target_sprite != null:
		_photographer = target_sprite
		var rest_y := target_sprite.position.y
		var idle_tween := target.create_tween().set_loops()
		idle_tween.tween_property(target_sprite, "position:y", rest_y - 2.0, 1.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		idle_tween.tween_property(target_sprite, "position:y", rest_y, 1.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_sortable_world.add_child(target)
	_targets[id] = target
	return target


func _request_walk(destination: Vector2) -> void:
	if _panorama: return
	var route := _pathfinder.find_path(_traveler.global_position, destination)
	if route.is_empty():
		_pending_target = null
		_traveler.cancel_path()
		_clear_destination()
		_ui.show_feedback("这里暂时无法通行，请换一处点击。")
		return
	_ui.set_destination(route[route.size() - 1])
	_destination_marker.position = route[route.size() - 1]
	_destination_marker.visible = true
	_traveler.set_path(route)


func _on_target_selected(target: ExplorationTarget) -> void:
	if _paused or _transitioning or _ui.has_modal():
		return
	_pending_target = target
	_request_walk(target.stand_position)


func _on_traveler_arrived() -> void:
	_clear_destination()
	if _pending_target == null or not is_instance_valid(_pending_target):
		return
	var target := _pending_target
	_pending_target = null
	if _traveler.global_position.distance_to(target.stand_position) > 26.0:
		return
	_activate_target(target)


func _on_traveler_blocked() -> void:
	_pending_target = null
	_clear_destination()
	_ui.show_feedback("前方有障碍，路线已停止；请点击附近空地重新规划。")


func _activate_target(target: ExplorationTarget) -> void:
	match target.target_kind:
		"tour_info":
			_tour.read(_scene_id)
			_save_tour()
			_ui.show_information(TourCatalog.STOPS[_scene_id].title, TourCatalog.STOPS[_scene_id].info)
		"tour_activity":
			_show_tour_activity()
		"tour_record":
			_show_tour_record()
		"palace_travel":
			_ui.close_modal()
			_transition_to("palace_garden")
		"post_office_return":
			_transition_to("outdoor")
		"palace_enter":
			_transition_to("palace_hall")
		"palace_exit":
			_transition_to("palace_garden")
		"palace_architecture":
			_record_palace_stop("architecture")
			_ui.show_information("独立宫 · 建筑与光影", Palace.INFO)
		"palace_view":
			_record_palace_stop("garden")
			_ui.show_information("在庭院停一会儿", Palace.VIEW)
		"palace_exhibit":
			_record_palace_stop("exhibit")
			_ui.show_information("独立宫 · 历史的一页", Palace.EXHIBIT)
		"palace_souvenir":
			_show_palace_visit()
		"info":
			if _postcard.read_sign():
				_save_postcard()
			_ui.show_information("Saigon Central Post Office", SIGN_BODY)
		"mailbox":
			if _postcard.stage() >= Postcard.Stage.POST_CARD:
				_show_postcard()
			else:
				_ui.show_information("旧邮筒", MAILBOX_BODY)
		"npc":
			_ui.show_dialogue("第一次来西贡吗？")
		"postcard":
			_show_postcard()
		"enter":
			_transition_to("indoor")
		"exit":
			_transition_to("outdoor")


func _on_dialogue_choice(choice_index: int) -> void:
	if choice_index < 0 or choice_index >= PHOTOGRAPHER_REPLIES.size():
		return
	_ui.show_dialogue_reply(PHOTOGRAPHER_REPLIES[choice_index])


func _clear_destination() -> void:
	_ui.clear_destination()
	if is_instance_valid(_destination_marker):
		_destination_marker.visible = false


func _near_target(id: String) -> bool:
	var target := _targets.get(id) as ExplorationTarget
	return target != null and _traveler.global_position.distance_to(target.stand_position) <= 26.0


func _update_postcard_hud() -> void:
	if TourCatalog.is_new_stop(_scene_id):
		_ui.set_stop_progress(TourCatalog.STOPS[_scene_id].title, _tour.stage(_scene_id), _tour_hint())
	elif _scene_id.begins_with("palace_"):
		_ui.set_visit_progress(_palace.stage(), Palace.HINTS[_palace.stage()])
	else:
		var hint: String = Postcard.HINTS[_postcard.stage()]
		if _postcard.sent:
			hint = "第一张明信片已寄出。点击「下一站」前往阮文平书街，或打开路线册自由选站。"
		_ui.set_quest_progress(_postcard.stage(), hint)
	var count := 0
	for completed: bool in _completed_stops().values():
		if completed: count += 1
	_ui.set_route_progress(count, not _next_stop_id().is_empty(), TourCatalog.STOPS.size())
	_ui.set_views(TourCatalog.views(_scene_id).size(), _view_index, _panorama)


func _show_current_journey() -> void:
	if TourCatalog.is_new_stop(_scene_id):
		_show_tour_record()
	elif _scene_id.begins_with("palace_"):
		_show_palace_visit()
	else:
		_show_postcard()


func _record_palace_stop(stop: String) -> void:
	if not _palace.record(stop):
		return
	_update_postcard_hud()
	var save_store := get_node_or_null("/root/SaveStore")
	if save_store != null and not save_store.call("set_palace_progress", _palace.serialize()):
		_ui.show_feedback("暂时无法保存；本次参观仍可继续。")


func _show_palace_visit() -> void:
	if _paused or _transitioning:
		return
	_traveler.cancel_path()
	_pending_target = null
	_clear_destination()
	_postcard_context = "palace_status"
	if _palace.stage() == 4:
		_ui.show_postcard("独立宫 · 旅行纪念", "独立宫参观完成 ✓\n\n庭院里的水声、立面的光影，还有大厅里留存的历史，成为今天旅途的新一页。\n\n打开旅行路线册，继续认识西贡。")
	elif _palace.stage() == 3 and _near_target("palace_souvenir"):
		_postcard_context = "palace_collect"
		_ui.show_postcard("为这一站留下纪念", "建筑、庭院与历史，已经串成今天的参观路线。收下一枚独立宫旅行纪念，记住这段慢慢走过的时光。", ["收下旅行纪念"])
	else:
		_ui.show_postcard(Palace.TITLE, Palace.HINTS[_palace.stage()])


func _save_postcard() -> void:
	_update_postcard_hud()
	var save_store := get_node_or_null("/root/SaveStore")
	if save_store != null and not save_store.call("set_postcard_progress", _postcard.serialize()):
		_ui.show_feedback("暂时无法保存；本次漫步仍可继续。")


func _show_postcard() -> void:
	if _paused or _transitioning:
		return
	_traveler.cancel_path()
	_pending_target = null
	_clear_destination()
	_postcard_context = "status"
	match _postcard.stage():
		Postcard.Stage.MEET_PHOTOGRAPHER:
			if _near_target("photographer"):
				_postcard_context = "offer"
				_ui.show_postcard(Postcard.TITLE, "摄影师递来一张空白明信片。\n“先看看邮局的故事，再进去写一句话吧。广场上的旧邮筒，会替你把问候寄出去。”", ["收下空白明信片"])
			else:
				_ui.show_postcard(Postcard.TITLE, Postcard.HINTS[0])
		Postcard.Stage.READ_SIGN:
			_ui.show_postcard("一张空白明信片", Postcard.HINTS[1])
		Postcard.Stage.WRITE_CARD:
			if _scene_id == "indoor" and _near_target("postcard_desk"):
				_postcard_context = "write"
				_ui.show_postcard("写下这一刻 · 西贡中央邮局", "坐在老邮局的书写台前，你想把哪一句话寄给远方的人？", Postcard.MESSAGES)
			else:
				_ui.show_postcard("空白明信片 · 已了解邮局", Postcard.HINTS[2])
		Postcard.Stage.POST_CARD:
			if _scene_id == "outdoor" and _near_target("old_mailbox"):
				_postcard_context = "send"
				_ui.show_postcard("投递前，再看一眼", "“%s”\n\n西贡中央邮局 · 你的第一张明信片，准备出发。" % _postcard.message(), ["投入旧邮筒"])
			else:
				_ui.show_postcard("明信片已写好", "“%s”\n\n%s" % [_postcard.message(), Postcard.HINTS[3]])
		Postcard.Stage.COMPLETE:
			_ui.show_postcard("明信片已寄出 · 西贡的第一份问候", "“%s”\n\n明信片落进邮筒，发出轻轻的一声响。\n这座城市的阳光与故事，正向远方出发。" % _postcard.message())


func _on_postcard_choice(index: int) -> void:
	if _paused or _transitioning or not _ui.has_modal():
		return
	var changed := false
	match _postcard_context:
		"tour_choice":
			if TourCatalog.is_new_stop(_scene_id) and _near_target("tour_activity") and _tour.choose(_scene_id, index):
				_save_tour()
				_postcard_context = "tour_status"
				_ui.show_information(TourCatalog.STOPS[_scene_id].activity, TourCatalog.STOPS[_scene_id].replies[index] + "\n\n" + _tour_hint())
			return
		"tour_record":
			if index == 0 and TourCatalog.is_new_stop(_scene_id) and _near_target("tour_record") and _tour.record(_scene_id):
				_save_tour()
				_show_tour_record()
			return
		"palace_collect":
			if index == 0 and _scene_id == "palace_hall" and _near_target("palace_souvenir"):
				_record_palace_stop("souvenir")
				_show_palace_visit()
			return
		"offer":
			if index == 0 and _near_target("photographer"):
				changed = _postcard.accept()
		"write":
			if _scene_id == "indoor" and _near_target("postcard_desk"):
				changed = _postcard.write_message(index)
		"send":
			if index == 0 and _scene_id == "outdoor" and _near_target("old_mailbox"):
				changed = _postcard.post()
	if changed:
		_save_postcard()
		_show_postcard()


func _transition_to(next_scene: String, view_index: int = 0) -> void:
	if _transitioning:
		return
	_transitioning = true
	# Remember each ground viewpoint independently for this play session.
	# Panoramas must never replace a safe ground position with Vector2.ZERO.
	if not _panorama and not TourCatalog.views(_scene_id).is_empty():
		_view_positions["%s/%d" % [_scene_id, _view_index]] = _traveler.global_position
		_ground_views[_scene_id] = _view_index
	_traveler.cancel_path()
	_pending_target = null
	_clear_destination()
	var fade_out := create_tween()
	fade_out.tween_property(_fade, "color:a", 0.96, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await fade_out.finished
	var spawn := Vector2(640, 620)
	if TourCatalog.is_new_stop(next_scene):
		spawn = TourWorld.layout(next_scene, view_index).get("spawn", spawn)
		spawn = _view_positions.get("%s/%d" % [next_scene, view_index], spawn)
	if not TourCatalog.is_new_stop(next_scene):
		spawn = {"indoor": Vector2(640, 575), "outdoor": Vector2(608, 432), "palace_garden": Vector2(640, 640), "palace_hall": Vector2(640, 620)}[next_scene]
	if next_scene == "palace_garden" and _scene_id == "palace_hall":
		spawn = Vector2(640, 352)
	if next_scene == "outdoor" and _scene_id == "palace_garden":
		spawn = Vector2(938, 620)
	_setup_scene(next_scene, spawn, view_index)
	await get_tree().process_frame
	var fade_in := create_tween()
	fade_in.tween_property(_fade, "color:a", 0.0, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await fade_in.finished
	_transitioning = false


func _toggle_pause() -> void:
	if _transitioning: return
	_set_paused(not _paused)


func _set_paused(paused: bool) -> void:
	_paused = paused
	get_tree().paused = paused
	_ui.set_paused(paused)
	var audio_director := get_node_or_null("/root/AudioDirector")
	if audio_director != null:
		audio_director.call("set_game_paused", paused)


func _return_to_start() -> void:
	_set_paused(false)
	_setup_scene("outdoor", Vector2(640.0, 622.0))
	_ui.show_feedback("旅程从西贡中央邮局前重新开始。")


func _open_licenses() -> void:
	OpenSourceLicenseHelper.open(self)


func _apply_tuning() -> void:
	var tuning_store := get_node_or_null("/root/TuningStore")
	if is_instance_valid(_traveler):
		var speed := 190.0
		if tuning_store != null:
			speed = float(tuning_store.call("get_value", "player.move.max_speed", speed))
		_traveler.set_walk_speed(speed)
	if is_instance_valid(_ui):
		var opacity := 0.96
		if tuning_store != null:
			opacity = float(tuning_store.call("get_value", "ui.hud.opacity", opacity))
		_ui.set_panel_opacity(opacity)


func _on_tuning_changed(_id: String, _requested: Variant, _active: Variant) -> void:
	_apply_tuning()
