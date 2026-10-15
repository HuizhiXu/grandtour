extends SceneTree

var failures: Array[String] = []
var checks := 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, context: String) -> void:
	checks += 1
	if not condition:
		failures.append(context)

func _run() -> void:
	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	var traveler := main.get("_traveler") as Traveler
	traveler.set_physics_process(false)
	var sprite := traveler.get_node("TravelerFrames") as AnimatedSprite2D
	var footprint := traveler.global_position
	for direction in [Vector2.DOWN, Vector2.LEFT, Vector2.UP, Vector2.RIGHT]:
		traveler.set_path(PackedVector2Array([footprint + direction * 100]))
		var seen := {}
		for step in range(18):
			await create_timer(0.04).timeout
			seen[sprite.frame] = true
		_check(seen.size() == 6, "full six-pose cycle advances in direction %s" % direction)
		_check(traveler.global_position == footprint, "visual hop cannot move the footprint")
	# Changing direction mid-stride must retain the current footfall phase.
	sprite.set_frame_and_progress(4, 0.3)
	traveler.set_path(PackedVector2Array([footprint + Vector2.LEFT * 100]))
	_check(sprite.frame == 4 and is_equal_approx(sprite.frame_progress, 0.3), "turn retains stride phase")
	traveler.cancel_path()
	var idle_seen := {}
	for step in range(60):
		await create_timer(0.04).timeout
		idle_seen[sprite.frame] = true
	_check(sprite.is_playing() and idle_seen.size() == 4, "idle keeps playing through attentive, tilt, blink and tail poses")
	_check(traveler.global_position == footprint and not traveler.is_walking(), "idle never moves the physical player")
	root.get_tree().paused = true
	var frozen_frame := sprite.frame
	var frozen_progress := sprite.frame_progress
	var frozen_visual := sprite.position
	await create_timer(0.2, true).timeout
	_check(sprite.frame == frozen_frame and is_equal_approx(sprite.frame_progress, frozen_progress) and sprite.position == frozen_visual, "pause freezes artwork as well as movement")
	root.get_tree().paused = false
	main.queue_free()
	await process_frame
	if failures.is_empty():
		print("[archie-animation] PASS: %d checks" % checks)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
