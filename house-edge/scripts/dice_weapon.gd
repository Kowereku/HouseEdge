extends Node2D

# Fires a bouncing die at the nearest on-screen enemy on a timer. Scales with
# level (granted/leveled by the slot machine's DICE upgrade).

@onready var timer = $Timer

var dice_scene = preload("res://scenes/dice.tscn")
var level: int = 0

func set_level(lv: int):
	level = lv
	if timer:
		timer.wait_time = maxf(0.5, 1.8 * pow(0.88, float(level - 1)))

func _on_timer_timeout():
	if level <= 0:
		return
	var enemies = get_tree().get_nodes_in_group("Enemy")
	if enemies.is_empty():
		return
	var view = _visible_world_rect()
	var nearest = null
	var best = INF
	for e in enemies:
		if view != null and not view.has_point(e.global_position):
			continue
		var d = global_position.distance_to(e.global_position)
		if d < best:
			best = d
			nearest = e
	if nearest != null:
		_fire(nearest)

func _fire(target):
	var d = dice_scene.instantiate()
	d.damage = 8 + (level - 1) * 3
	@warning_ignore("integer_division")
	d.max_hits = 3 + (level - 1) / 2
	get_tree().current_scene.add_child(d)
	d.global_position = global_position
	d.current_target = target
	Audio.play_sfx("shoot")

func _visible_world_rect():
	var cam = get_viewport().get_camera_2d()
	if cam == null:
		return null
	var size: Vector2 = get_viewport().get_visible_rect().size / cam.zoom
	return Rect2(cam.get_screen_center_position() - size * 0.5, size)
