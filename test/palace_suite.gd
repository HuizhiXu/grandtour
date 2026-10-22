extends SceneTree

const MAIN := preload("res://scenes/main.tscn")
var _failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var main := MAIN.instantiate()
	root.add_child(main)
	await process_frame
	main.call("_setup_scene", "palace_garden", Vector2(640, 640))
	var ui := main.get("_ui") as ExplorationUI
	ui.close_modal()
	_check((main.get("_targets") as Dictionary).is_empty(), "palace no longer offers visit tasks or an entrance quest")
	_check(not main.has_method("_show_palace_visit"), "souvenir collection removed")
	var pathfinder = main.get("_pathfinder")
	_check(not pathfinder.is_world_walkable(Vector2(645, 478)), "scenic lawn boundary retained")
	_check(not pathfinder.is_world_walkable(Vector2(640, 220)), "facade boundary retained")
	(ui.get("_quest_button") as Button).pressed.emit()
	_check(ui.has_modal(), "palace introduction opens directly")
	_check("1966" in (ui.get("_modal_body") as Label).text, "palace retains architectural introduction")
	ui.close_modal()
	main.call("_setup_scene", "outdoor", Vector2(640, 622))
	_check((ui.get("_quest_button") as Button).text == "查看明信片", "return restores post office quest HUD")
	_check((main.get("_targets") as Dictionary).has("photographer"), "post office photographer remains")
	main.queue_free()
	await process_frame
	if _failures.is_empty(): print("[palace-tests] PASS: 8 scenic palace and post office checks")
	for failure: String in _failures: push_error(failure)
	quit(0 if _failures.is_empty() else 1)

func _check(condition: bool, label: String) -> void:
	if not condition: _failures.append(label)
