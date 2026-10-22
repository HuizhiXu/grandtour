extends RefCounted
## Calibrated against the final 16:9 paintings at 1280 x 720.

static func layout(id: String, _view_index: int = 0) -> Dictionary:
	var floor := PackedVector2Array()
	var spawn := Vector2.ZERO
	match id:
		"datong_yungang":
			# Only paving below the barrier; the tree and stone carvings stay outside.
			floor = PackedVector2Array([Vector2(250, 660), Vector2(700, 640), Vector2(1150, 628), Vector2(1150, 720), Vector2(250, 720)])
			spawn = Vector2(640, 680)
		"datong_nine_dragon_wall":
			# Foreground paving only, below the reflecting pool and its stone posts.
			floor = PackedVector2Array([Vector2(100, 600), Vector2(600, 620), Vector2(1180, 650), Vector2(1180, 720), Vector2(100, 720)])
			spawn = Vector2(700, 680)
	return {
		"floor": floor, "spawn": spawn, "panorama": floor.is_empty(),
		"obstacles": [] as Array[Rect2], "info": Vector2.ZERO, "info_stand": spawn,
		"activity": Vector2.ZERO, "activity_stand": spawn
	}
