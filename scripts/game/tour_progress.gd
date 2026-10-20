extends RefCounted

## Legacy save compatibility for the retired three-choice activities.
const LEGACY_CHOICE_COUNT := 3
const Catalog := preload("res://scripts/game/tour_catalog.gd")
var _stops: Dictionary = {}

func state(id: String) -> Dictionary:
	return _stops.get(id, {"read": false, "choice": -1, "recorded": false}).duplicate(true)

func stage(id: String) -> int:
	var entry := state(id)
	if entry.recorded: return 3
	return int(entry.read) + int(entry.choice >= 0)

func read(id: String) -> void:
	if not Catalog.is_new_stop(id): return
	var entry := state(id)
	entry.read = true
	_stops[id] = entry

func choose(id: String, choice: int) -> bool:
	if not Catalog.is_new_stop(id) or choice < 0 or choice >= LEGACY_CHOICE_COUNT: return false
	var entry := state(id)
	if entry.recorded: return false
	entry.choice = choice
	_stops[id] = entry
	return true

func record(id: String) -> bool:
	if stage(id) != 2: return false
	var entry := state(id)
	entry.recorded = true
	_stops[id] = entry
	return true

func serialize() -> Dictionary:
	return _stops.duplicate(true)

func restore(data: Dictionary) -> void:
	_stops.clear()
	for id: String in Catalog.STOPS:
		if not Catalog.is_new_stop(id) or not data.get(id) is Dictionary: continue
		var raw: Dictionary = data[id]
		var value: Variant = raw.get("choice", -1)
		var choice := int(value) if value is int or value is float else -1
		if choice < 0 or choice >= LEGACY_CHOICE_COUNT: choice = -1
		var read_done: bool = raw.get("read", false) == true
		_stops[id] = {"read": read_done, "choice": choice, "recorded": raw.get("recorded", false) == true and read_done and choice >= 0}
