extends SceneTree

const TourCatalog := preload("res://scripts/game/tour_catalog.gd")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_verify")


func _verify() -> void:
	_check(ProjectSettings.get_setting("application/config/name") == "The Grand Tour", "exported game identity")
	for path: String in [
		"assets/game/runtime/saigon-exterior.jpg",
		"assets/game/runtime/post-office-interior.jpg",
		"assets/game/runtime/independence-palace.jpg",
		"assets/game/runtime/independence-palace-hall.jpg",
		"assets/game/runtime/archie-atlas.png",
		"assets/game/runtime/archie-idle-atlas.png",
		"assets/game/runtime/photographer-npc.png",
		"assets/game/runtime/intro-sign.png",
		"assets/game/runtime/old-mailbox.png",
		"assets/share/favicon.png",
	]:
		_check(ResourceLoader.exists("res://" + path), "game resource: " + path)
	for font_path: String in [
		"fonts/ui_regular.tres",
		"fonts/ui_medium.tres",
		"fonts/ui_bold.tres",
		"fonts/NotoSans-Vietnamese.subset.woff2",
		"fonts/display/generic_heading.tres",
	]:
		_check(ResourceLoader.exists("res://assets/template/" + font_path), "shared font: " + font_path)
	_check(not ResourceLoader.exists("res://assets/game/scenes/saigon-exterior.png"), "large source background excluded")
	_check(not ResourceLoader.exists("res://assets/game/scenes/independence-palace.png"), "palace source background excluded")
	for id: String in TourCatalog.STOPS:
		if not TourCatalog.is_new_stop(id): continue
		_check(ResourceLoader.exists(TourCatalog.background_path(id)), "exported tour background: " + id)
		_check(not ResourceLoader.exists("res://assets/game/scenes/tour-%s.png" % id), "tour source background excluded: " + id)
	_check(not ResourceLoader.exists("res://assets/game/characters/traveler-sheet.png"), "source character atlas excluded")
	_check(not ResourceLoader.exists("res://test/exploration_suite.gd"), "test script excluded")
	_check(not ResourceLoader.exists("res://tools/capture_native.gd"), "native capture tool excluded")
	_check(not root.has_node("GlobalLeaderboard"), "no dormant network autoload")
	_check(not DirAccess.dir_exists_absolute("res://assets/template/generated"), "retired creative assets excluded")
	_check(not DirAccess.dir_exists_absolute("res://assets/template/audio"), "no default audio assets")
	var font := load("res://assets/template/fonts/ui_regular.tres") as Font
	_check(font != null, "exported UI font")
	for character: String in "Ngô Viết Thụ":
		_check(font != null and font.has_char(character.unicode_at(0)), "exported architect name glyph: " + character)
	for locale: String in ["en", "zh-CN"]:
		var locale_path := "res://localization/%s.json" % locale
		_check(FileAccess.file_exists(locale_path), "exported locale: " + locale)
		if FileAccess.file_exists(locale_path):
			var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(locale_path))
			for value: String in catalog.values():
				for index: int in value.length():
					var codepoint := value.unicode_at(index)
					if codepoint >= 32:
						_check(font != null and font.has_char(codepoint), "exported glyph: %d" % codepoint)

	var packed := load("res://scenes/main.tscn") as PackedScene
	_check(packed != null, "exported main scene")
	if packed != null:
		var main := packed.instantiate()
		root.add_child(main)
		await process_frame
		await process_frame
		_check(str(main.get("_scene_id")) == "outdoor", "pack boots directly into the street")
		_check(main.get("_traveler") is CharacterBody2D, "pack creates a controllable traveler")
		var targets: Dictionary = main.get("_targets")
		for target_id: String in ["post_office_info", "old_mailbox", "photographer", "post_office_door"]:
			_check(targets.has(target_id), "pack target: " + target_id)
		_check(main.has_method("_request_walk"), "pack retains click-to-move routing")
		_check(targets.has("palace_travel"), "pack includes next stop route")
		main.call("_setup_scene", "palace_garden", Vector2(640, 640))
		_check((main.get("_targets") as Dictionary).has("palace_door"), "pack builds palace garden")
		main.call("_setup_scene", "palace_hall", Vector2(640, 620))
		_check((main.get("_targets") as Dictionary).has("palace_souvenir"), "pack builds palace hall")
		for id: String in TourCatalog.STOPS:
			if not TourCatalog.is_new_stop(id): continue
			main.call("_setup_scene", id, Vector2(640, 620))
			var observation_only: bool = TourCatalog.STOPS[id].get("observation_only", false)
			_check((main.get("_targets") as Dictionary).has("tour_activity") != observation_only, "pack builds correct tour interaction mode: " + id)
			var guidance := (main.get("_ui") as Control).get("_exploration_button") as Button
			_check(guidance != null and guidance.visible == id.begins_with("angkor_"), "pack includes Angkor walking guidance: " + id)
			for view_index in range(TourCatalog.views(id).size()):
				_check(ResourceLoader.exists(TourCatalog.background_path(id, view_index)), "pack includes view: %s/%d" % [id, view_index])
				main.call("_setup_scene", id, Vector2(640, 620), view_index)
				_check(main.get("_view_index") == view_index, "pack switches view: %s/%d" % [id, view_index])
				if main.get("_panorama"):
					_check(guidance.visible == observation_only, "pack uses observation actions only at observation stops: " + id)
					_check(not (main.get("_traveler") as Node2D).visible, "pack hides walking actor in panoramas: " + id)
			if not TourCatalog.views(id).is_empty():
				main.call("_show_views")
				var ui := main.get("_ui") as Control
				var actions := ui.get("_modal_actions") as VBoxContainer
				_check(actions.get_child_count() == TourCatalog.views(id).size() + 1, "pack builds all view preview choices: " + id)
				for index in range(mini(TourCatalog.views(id).size(), actions.get_child_count())):
					var button := actions.get_child(index) as Button
					_check(button != null and button.icon != null, "pack loads view preview: %s/%d" % [id, index])
				ui.call("close_modal")
		_check(not main.has_method("_maybe_capture"), "capture routing removed from runtime")
		_check(not main.has_method("_open_tuning"), "release tuning entry point excluded")
		_check(not ResourceLoader.exists("res://scripts/ui/tuning_panel.gd"), "release tuning panel excluded")
		var audio := root.get_node("AudioDirector")
		_check(not bool(audio.call("play_cue", "ui.confirm")), "pack missing SFX is silent")
		_check(not bool(audio.call("play_music", "music.gameplay")), "pack missing BGM is silent")
		audio.call("release_streams")
		main.queue_free()
		await process_frame

	if _failures.is_empty():
		print("[exported-pack] PASS: identity, art, fonts, exclusions, playable entry and targets")
		quit(0)
	else:
		for failure: String in _failures:
			push_error("[exported-pack] " + failure)
		quit(1)


func _check(condition: bool, context: String) -> void:
	if not condition and context not in _failures:
		_failures.append(context)
