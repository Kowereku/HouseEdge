extends Node2D

# Pistol weapon: fast fire, low damage. Targets the nearest on-screen enemy.
# Unlocked/leveled via the slot machine (the pistol symbol).

@onready var timer = $Timer

var bullet_scene = preload("res://scenes/bullet.tscn")
var level: int = 0

func set_level(lv: int):
	level = lv
	if timer:
		timer.wait_time = maxf(0.12, 0.5 * pow(0.88, float(level - 1)))

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
	var dmg: int = 2 + level  # low per-shot, fast fire
	@warning_ignore("integer_division")
	var shots: int = 1 + level / 4  # extra bullets every 4 levels
	var base_dir = global_position.direction_to(target.global_position)
	for i in shots:
		var spread := deg_to_rad((float(i) - float(shots - 1) * 0.5) * 9.0)
		var b = bullet_scene.instantiate()
		b.damage = dmg
		b.direction = base_dir.rotated(spread)
		get_tree().current_scene.add_child(b)
		b.global_position = global_position
		b.rotation = b.direction.angle()
	Audio.play_sfx("shoot")

func _visible_world_rect():
	var cam = get_viewport().get_camera_2d()
	if cam == null:
		return null
	var size: Vector2 = get_viewport().get_visible_rect().size / cam.zoom
	return Rect2(cam.get_screen_center_position() - size * 0.5, size)
