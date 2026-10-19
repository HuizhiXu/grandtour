extends SceneTree
# Native renderer evidence only; tools/ is excluded from playable exports.
const MAIN = preload("res://scenes/main.tscn")
const Catalog = preload("res://scripts/game/tour_catalog.gd")
func _initialize() -> void:
	call_deferred("_capture")
func _capture() -> void:
	var output := OS.get_environment("GRANDTOUR_CAPTURE_PATH")
	if output.is_empty(): output = OS.get_environment("GENERIC2D_CAPTURE_PATH")
	if output.is_empty():
		push_error("GRANDTOUR_CAPTURE_PATH must name an output PNG")
		quit(1)
		return
	var main := MAIN.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	var stop := OS.get_environment("GRANDTOUR_CAPTURE_STOP")
	if not stop.is_empty():
		if not Catalog.STOPS.has(stop):
			push_error("Unknown capture stop: " + stop)
			quit(1)
			return
		main.call("_travel_to_stop", stop)
		while main.get("_transitioning"): await process_frame
	var view := OS.get_environment("GRANDTOUR_CAPTURE_VIEW")
	if not view.is_empty():
		var index := view.to_int()
		if not view.is_valid_int() or index < 0 or index >= Catalog.views(stop).size():
			push_error("Invalid capture viewpoint: " + view)
			quit(1)
			return
		main.call("_select_view", index)
		while main.get("_transitioning"): await process_frame
	if OS.get_environment("GENERIC2D_CAPTURE_PAUSE") == "1" or OS.get_environment("GRANDTOUR_CAPTURE_PAUSE") == "1":
		main.call("_set_paused", true)
	for frame in range(8): await process_frame
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png(output)
	print("[capture] %s (%s)" % [output, error_string(error)])
	root.get_node("AudioDirector").release_streams()
	quit(0 if error == OK else 1)
