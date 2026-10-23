extends RefCounted
## Ground is calibrated only after the referenced final paintings are inspected.

static func layout(_id: String, _view_index: int = 0) -> Dictionary:
	return {
		"floor": PackedVector2Array(), "spawn": Vector2.ZERO, "panorama": true,
		"obstacles": [] as Array[Rect2], "info": Vector2.ZERO, "info_stand": Vector2.ZERO,
		"activity": Vector2.ZERO, "activity_stand": Vector2.ZERO
	}
