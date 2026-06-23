extends Label

# Floating damage text. Call setup() right after adding it to the world.
func setup(value: int, world_pos: Vector2) -> void:
	add_to_group("dmg_number")
	text = str(value)
	z_index = 100
	global_position = world_pos + Vector2(randf_range(-8.0, 8.0), -10.0)
	var start_y: float = global_position.y
	var tw := create_tween().set_parallel(true)
	tw.tween_property(self, "global_position:y", start_y - 38.0, 0.5)
	tw.tween_property(self, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN)
	tw.finished.connect(queue_free)
