extends Node2D

# Roulette ball(s) orbiting the player, damaging enemies they sweep through.
# One full rotation every `period` seconds. Unlocked/leveled via the slot machine.

@export var period: float = 6.0  # seconds per full rotation
@export var radius: float = 115.0

var ball_scene = preload("res://scenes/roulette_ball.tscn")
var level: int = 0
var damage: int = 6
var ball_count: int = 1
var _angle: float = 0.0
var _balls: Array = []
var _cooldowns: Array = []  # per ball: { enemy_id: seconds_left }

func set_level(lv: int):
	level = lv
	damage = 4 + lv * 2  # L1=6, L5=14, L10=24 (per sweep, 0.5s cooldown per enemy)
	@warning_ignore("integer_division")
	ball_count = 1 + (lv - 1) / 2  # +1 ball every 2 levels
	period = maxf(3.2, 6.0 - float(lv - 1) * 0.3)  # speeds up a bit per level
	_rebuild_balls()

func _rebuild_balls():
	for b in _balls:
		if is_instance_valid(b):
			b.queue_free()
	_balls.clear()
	_cooldowns.clear()
	for i in ball_count:
		var b = ball_scene.instantiate()
		add_child(b)
		b.top_level = true  # position the ball in absolute/world space
		_balls.append(b)
		_cooldowns.append({})

func _physics_process(delta):
	if level <= 0 or _balls.is_empty():
		return
	_angle += (TAU / period) * delta
	var center := global_position
	for i in _balls.size():
		var a := _angle + TAU * float(i) / float(_balls.size())
		var b = _balls[i]
		b.global_position = center + Vector2(radius, 0.0).rotated(a)
		_damage_overlaps(b, i, delta)

func _damage_overlaps(ball, idx: int, delta: float):
	var cds: Dictionary = _cooldowns[idx]
	for id in cds.keys():
		cds[id] -= delta
		if cds[id] <= 0.0:
			cds.erase(id)
	for body in ball.get_overlapping_bodies():
		if not body.is_in_group("Enemy"):
			continue
		var id = body.get_instance_id()
		if cds.has(id):
			continue
		if "alive" in body and not body.alive:
			continue
		body.take_damage(damage, ball.global_position)
		cds[id] = 0.45  # same enemy can be hit again after this many seconds
