extends SceneTree

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_verify")


func _verify() -> void:
	_check(ProjectSettings.get_setting("application/config/name") == "The Grand Tour", "exported game identity")
	for path: String in [
		"assets/game/runtime/saigon-exterior.jpg",
		"assets/game/runtime/post-office-interior.jpg",
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
		"fonts/display/generic_heading.tres",
	]:
		_check(ResourceLoader.exists("res://assets/template/" + font_path), "shared font: " + font_path)
	_check(not ResourceLoader.exists("res://assets/game/scenes/saigon-exterior.png"), "large source background excluded")
	_check(not ResourceLoader.exists("res://assets/game/characters/traveler-sheet.png"), "source character atlas excluded")
	_check(not ResourceLoader.exists("res://test/exploration_suite.gd"), "test script excluded")
	_check(not ResourceLoader.exists("res://tools/capture_native.gd"), "native capture tool excluded")
	_check(not root.has_node("GlobalLeaderboard"), "no dormant network autoload")
	_check(not DirAccess.dir_exists_absolute("res://assets/template/generated"), "retired creative assets excluded")
	_check(not DirAccess.dir_exists_absolute("res://assets/template/audio"), "no default audio assets")
	var font := load("res://assets/template/fonts/ui_regular.tres") as Font
	_check(font != null, "exported UI font")
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
