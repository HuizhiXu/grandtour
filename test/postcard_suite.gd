extends SceneTree

const MAIN := preload("res://scenes/main.tscn")
const Quest := preload("res://scripts/game/postcard_quest.gd")

var _checks := 0
var _failures: Array[String] = []
var _original_save: Dictionary
var _capture_dir := ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var saves := root.get_node("SaveStore")
	_original_save = saves.get("_data").duplicate(true)
	saves.get("_data")["last_travel_stop"] = ""
	saves.set_postcard_progress({})
	_capture_dir = OS.get_environment("GRANDTOUR_CAPTURE_DIR")
	if not _capture_dir.is_empty():
		DirAccess.make_dir_recursive_absolute(_capture_dir)
	_test_quest_rules()
	var main := MAIN.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	var ui := main.get("_ui") as ExplorationUI
	ui.close_modal()
	var traveler := main.get("_traveler") as Traveler
	await _capture("01-street")
	await _test_movement(main)

	main.call("_request_walk", Vector2(700, 560))
	for frame in range(5):
		await physics_frame
	main.call("_show_postcard")
	_check(not traveler.is_walking(), "opening the postcard stops the active route")
	_check(_stage(main) == Quest.Stage.MEET_PHOTOGRAPHER, "the HUD cannot grant a postcard from a distance")
	ui.close_modal()
	await process_frame
	await _approach(main, "old_mailbox")
	_check(_stage(main) == Quest.Stage.MEET_PHOTOGRAPHER, "visiting the mailbox early cannot finish the task")
	ui.close_modal()
	await process_frame

	await _approach(main, "photographer")
	_press_action(ui, "我想寄一张明信片。")
	await process_frame
	_check(_stage(main) == Quest.Stage.MEET_PHOTOGRAPHER, "the offer waits for explicit acceptance")
	_press_action(ui, "收下空白明信片")
	await process_frame
	_check(_stage(main) == Quest.Stage.READ_SIGN, "accepting starts the four-step postcard task")
	await _capture("02-postcard-accepted")
	ui.close_modal()
	await process_frame

	await _approach(main, "post_office_info")
	_check(_stage(main) == Quest.Stage.WRITE_CARD, "reading the building sign unlocks writing")
	ui.close_modal()
	await process_frame
	await _approach(main, "post_office_door", "indoor")
	_check(main.get("_scene_id") == "indoor", "the porch still opens the hall during the task")
	await _capture("03-hall")
	await _approach(main, "postcard_desk")
	await _assert_modal_layout(ui)
	await _capture("04-choose-message")
	_check(_stage(main) == Quest.Stage.WRITE_CARD, "the writing desk waits for a greeting choice")
	_press_action(ui, Quest.MESSAGES[2])
	await process_frame
	_check(_stage(main) == Quest.Stage.POST_CARD, "choosing a greeting creates the written postcard")
	_check((ui.get("_modal_body") as Label).text.contains(Quest.MESSAGES[2]), "the postcard preview contains the selected greeting")
	var restored := Quest.new()
	restored.restore(saves.get_postcard_progress())
	_check(restored.stage() == Quest.Stage.POST_CARD and restored.message() == Quest.MESSAGES[2], "the selected greeting and unfinished progress are saved")
	ui.close_modal()
	await process_frame
	await _approach(main, "outdoor_exit", "outdoor")
	_check(_stage(main) == Quest.Stage.POST_CARD, "returning outside preserves the written card")
	await _approach(main, "old_mailbox")
	await _assert_modal_layout(ui)
	_check(_stage(main) == Quest.Stage.POST_CARD, "approaching the mailbox does not send automatically")
	_press_action(ui, "稍后再说")
	await process_frame
	_check(_stage(main) == Quest.Stage.POST_CARD and not ui.has_modal(), "cancelling delivery preserves the written card")
	await _approach(main, "old_mailbox")
	_press_action(ui, "投入旧邮筒")
	await process_frame
	_check(_stage(main) == Quest.Stage.COMPLETE, "confirming delivery completes the task")
	await _assert_modal_layout(ui)
	await _capture("05-postcard-sent")
	main.call("_on_postcard_choice", 0)
	_check(_stage(main) == Quest.Stage.COMPLETE, "repeated delivery cannot restart or duplicate the task")
	ui.close_modal()
	main.call("_return_to_start")
	_check(_stage(main) == Quest.Stage.COMPLETE, "return to the street entrance keeps completed progress")
	main.queue_free()
	await process_frame
	saves.call("_load")
	main = MAIN.instantiate()
	root.add_child(main)
	await process_frame
	_check(_stage(main) == Quest.Stage.COMPLETE, "reloading the save and scene restores completion")
	_check((main.get("_postcard") as PostcardQuest).message() == Quest.MESSAGES[2], "reloading preserves the chosen greeting")
	main.call("_show_postcard")
	await process_frame
	await process_frame
	await _assert_modal_layout(main.get("_ui") as ExplorationUI)
	main.queue_free()
	await process_frame
	saves.set("_data", _original_save)
	saves.save()
	if _failures.is_empty():
		print("[postcard-tests] PASS: %d movement, layout and quest checks" % _checks)
		quit(0)
	else:
		for failure in _failures:
			push_error("[postcard-tests] " + failure)
		print("[postcard-tests] FAIL: %d failures across %d checks" % [_failures.size(), _checks])
		quit(1)


func _test_quest_rules() -> void:
	var quest := Quest.new()
	_check(not quest.post() and not quest.write_message(0), "task rules reject writing or sending before accepting")
	quest.read_sign()
	quest.accept()
	_check(quest.stage() == Quest.Stage.WRITE_CARD, "a sign read before accepting is remembered")
	_check(not quest.write_message(-1) and not quest.write_message(3), "invalid greeting choices cannot advance the task")
	for index in range(Quest.MESSAGES.size()):
		var branch := Quest.new()
		branch.accept()
		branch.read_sign()
		_check(branch.write_message(index) and branch.message() == Quest.MESSAGES[index], "greeting branch %d can be selected" % index)
		_check(branch.post() and not branch.post(), "greeting branch %d can only be delivered once" % index)
	quest.restore({"accepted": true, "sent": true, "message_index": 99})
	_check(quest.stage() == Quest.Stage.READ_SIGN and not quest.sent, "inconsistent saved progress cannot forge completion")


func _test_movement(main: Node) -> void:
	var traveler := main.get("_traveler") as Traveler
	var ui := main.get("_ui") as ExplorationUI
	await _walk(main, Vector2(640, 560))
	var directions: Array[Vector2] = [Vector2.RIGHT, Vector2(2, 1), Vector2.DOWN, Vector2(-2, 1), Vector2.LEFT, Vector2(-2, -1), Vector2.UP, Vector2(2, -1)]
	for index in range(directions.size()):
		var destination := Vector2(640, 560) + directions[index].normalized() * 70.0
		main.call("_request_walk", destination)
		for frame in range(6):
			await physics_frame
		await _capture("direction-%d" % index)
		await _wait_for_walk(traveler)
		_check(traveler.global_position.distance_to(destination) < 1.0, "movement reaches direction %d without getting stuck" % index)
		_check(not (main.get("_destination_marker") as Line2D).visible, "direction %d clears the destination marker on arrival" % index)
		await _walk(main, Vector2(640, 560))
	main.call("_request_walk", Vector2(800, 580))
	for frame in range(6):
		await physics_frame
	main.call("_set_paused", true)
	var paused_at := traveler.global_position
	for frame in range(8):
		await physics_frame
	_check(traveler.global_position == paused_at, "pause freezes the moving traveler")
	main.call("_set_paused", false)
	main.call("_request_walk", Vector2(540, 580))
	await _wait_for_walk(traveler)
	_check(traveler.global_position.distance_to(Vector2(540, 580)) < 1.0, "a new click replaces the route after resuming")
	main.call("_request_walk", Vector2(900, 350))
	var resolved := traveler.current_destination()
	_check(resolved.distance_to(Vector2(900, 350)) > 18, "wall clicks resolve to nearby ground")
	await _wait_for_walk(traveler)
	_check(traveler.global_position.distance_to(resolved) < 1.0, "the traveler actually reaches the adjusted wall destination")
	_check(not ui.has_modal(), "movement checks do not accidentally activate a target")


func _walk(main: Node, destination: Vector2) -> void:
	main.call("_request_walk", destination)
	await _wait_for_walk(main.get("_traveler") as Traveler)


func _wait_for_walk(traveler: Traveler) -> void:
	for frame in range(900):
		await physics_frame
		if not traveler.is_walking():
			return
	_check(false, "walking completes within the bounded timeout")


func _approach(main: Node, id: String, expected_scene: String = "") -> void:
	var target := (main.get("_targets") as Dictionary).get(id) as ExplorationTarget
	_check(target != null, "interactive target exists: " + id)
	if target == null:
		return
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	target.call("_on_input_event", root, click, 0)
	for frame in range(900):
		await physics_frame
		if not expected_scene.is_empty():
			if main.get("_scene_id") == expected_scene and not main.get("_transitioning"):
				return
		elif (main.get("_ui") as ExplorationUI).has_modal():
			await process_frame
			return
	_check(false, "approaching activates target: " + id)


func _press_action(ui: ExplorationUI, text: String) -> void:
	for action in (ui.get("_modal_actions") as VBoxContainer).get_children():
		if action is Button and action.text == text:
			action.pressed.emit()
			return
	_check(false, "modal action exists: " + text)


func _assert_modal_layout(ui: ExplorationUI) -> void:
	# Containers apply text wrapping and minimum-size changes on deferred layout passes.
	await process_frame
	await process_frame
	var panel := ui.get("_modal_panel") as PanelContainer
	var viewport := Rect2(Vector2.ZERO, Vector2(1280, 720))
	_check(viewport.encloses(panel.get_global_rect()), "the postcard panel fits inside the viewport: %s %s" % [(ui.get("_modal_title") as Label).text, panel.get_global_rect()])
	for child in (ui.get("_modal_actions") as VBoxContainer).get_children():
		if child is Button:
			_check(panel.get_global_rect().encloses(child.get_global_rect()), "postcard action fits inside the panel: " + child.text)


func _capture(name: String) -> void:
	if _capture_dir.is_empty():
		return
	await process_frame
	await RenderingServer.frame_post_draw
	var picture := root.get_texture().get_image()
	_check(picture != null and not picture.is_empty(), "real renderer produces image: " + name)
	if picture != null:
		picture.save_png(_capture_dir.path_join(name + ".png"))


func _stage(main: Node) -> int:
	return (main.get("_postcard") as PostcardQuest).stage()


func _check(condition: bool, context: String) -> void:
	_checks += 1
	if not condition and context not in _failures:
		_failures.append(context)
