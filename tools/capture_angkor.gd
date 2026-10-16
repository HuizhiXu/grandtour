extends SceneTree
const MAIN := preload("res://scenes/main.tscn")
const Catalog := preload("res://scripts/game/tour_catalog.gd")
const World := preload("res://scripts/game/tour_world.gd")
func _initialize() -> void:
	call_deferred("_capture")
func _capture() -> void:
	var main := MAIN.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	var directory := OS.get_environment("GRANDTOUR_CAPTURE_DIR")
	DirAccess.make_dir_recursive_absolute(directory)
	for id: String in Catalog.ROUTES[2].stops:
		main.call("_setup_scene", id, World.layout(id).spawn)
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(directory.path_join(id + ".png"))
	main.set("_route_index", 2)
	main.call("_show_routes")
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(directory.path_join("angkor-routes.png"))
	root.get_node("AudioDirector").release_streams()
	quit()
