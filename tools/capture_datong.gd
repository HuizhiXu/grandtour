extends SceneTree
## Real-renderer review of the library, journey routes, and every Datong painting.
const MAIN := preload("res://scenes/main.tscn")
const Catalog := preload("res://scripts/game/tour_catalog.gd")
var _main: Node
var _output := ""

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_output = OS.get_environment("GRANDTOUR_CAPTURE_DIR")
	if _output.is_empty():
		push_error("GRANDTOUR_CAPTURE_DIR must name the screenshot directory")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute(_output)
	var store := root.get_node("SaveStore")
	var original: Dictionary = store.get("_data").duplicate(true)
	_main = MAIN.instantiate()
	root.add_child(_main)
	await _capture("00-library")
	for journey: Dictionary in Catalog.JOURNEYS:
		_main.call("_select_journey", str(journey.id))
		await _capture("01-route-" + str(journey.id))
	for id: String in Catalog.Datong.ROUTE.stops:
		_main.call("_travel_to_stop", id)
		while _main.get("_transitioning"): await process_frame
		await create_timer(2.4).timeout
		await _capture(id)
	store.set("_data", original)
	store.save()
	root.get_node("AudioDirector").release_streams()
	quit()

func _capture(name: String) -> void:
	for frame in range(8): await process_frame
	await RenderingServer.frame_post_draw
	var path := _output.path_join(name + ".png")
	var error := root.get_texture().get_image().save_png(path)
	if error != OK:
		push_error("Capture failed: " + path)
		quit(1)
	print("[capture] " + path)
