extends SceneTree
## Review the actual game renderer, library, city tabs, and official-photo paintings.
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
	if OS.get_environment("GRANDTOUR_CAPTURE_LIBRARY_ONLY") == "1":
		store.set("_data", original)
		store.save()
		root.get_node("AudioDirector").release_streams()
		quit()
		return
	_main.call("_select_journey", "hexi")
	for index: int in Catalog.journey("hexi").routes:
		_main.set("_route_index", index)
		_main.call("_show_routes")
		await _capture("01-city-%d" % index)
		if index == 5:
			var scroll := (_main.get("_ui") as Control).find_child("RouteStops", true, false) as ScrollContainer
			var grid := scroll.get_child(0)
			scroll.ensure_control_visible(grid.get_child(grid.get_child_count() - 1) as Control)
			await _capture("01-wuwei-last-stops")
	for id: String in Catalog.Hexi.STOPS:
		_main.call("_travel_to_stop", id)
		while _main.get("_transitioning"): await process_frame
		await create_timer(2.4).timeout
		await _capture(id)
		if id == "hexi_mogao":
			_main.call("_show_current_journey")
			await _capture("02-mogao-introduction")
			(_main.get("_ui") as Control).call("close_modal")
	store.set("_data", original)
	store.save()
	root.get_node("AudioDirector").release_streams()
	quit()

func _capture(label: String) -> void:
	for frame in range(8): await process_frame
	await RenderingServer.frame_post_draw
	var path := _output.path_join(label + ".png")
	var error := root.get_texture().get_image().save_png(path)
	if error != OK:
		push_error("Capture failed: " + path)
		quit(1)
	print("[capture] " + path)
