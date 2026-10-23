extends SceneTree
## Capture the actual library, four region pages, and every Turkey stop.
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
	_main.call("_select_journey", "turkey")
	for index: int in Catalog.journey("turkey").routes:
		_main.set("_route_index", index)
		_main.call("_show_routes")
		await _capture("01-region-%d" % index)
		var scroll := (_main.get("_ui") as Control).find_child("RouteStops", true, false) as ScrollContainer
		var grid := scroll.get_child(0)
		scroll.ensure_control_visible(grid.get_child(grid.get_child_count() - 1) as Control)
		await _capture("02-region-last-%d" % index)
	for id: String in Catalog.Turkey.STOPS:
		_main.call("_travel_to_stop", id)
		while _main.get("_transitioning"): await process_frame
		await create_timer(2.3).timeout
		await _capture(id)
		if id in ["turkey_sirkeci", "turkey_innocence", "turkey_aspendos"]:
			_main.call("_show_current_journey")
			await _capture(id + "-introduction")
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
