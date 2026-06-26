extends Area2D

# Bouncing dice projectile: homes to a target enemy, and on hit ricochets to the
# nearest not-yet-hit enemy, up to max_hits times, with slight damage falloff.

@export var speed: float = 520.0
var damage: int = 8
var max_hits: int = 3
var falloff: float = 0.8
var bounce_range: float = 340.0
var current_target: Node2D = null

var _dmg: float = 0.0
var _hits: int = 0
var _hit_ids: Array = []
var _life: float = 0.0

func _ready():
	_dmg = float(damage)

func _physics_process(delta):
	_life += delta
	if _life > 4.0:  # safety: never live forever
		queue_free()
		return
	if not _target_valid():
		_retarget()
		if current_target == null:
			queue_free()
			return
	var dir := global_position.direction_to(current_target.global_position)
	global_position += dir * speed * delta
	rotation += 9.0 * delta  # spin

func _target_valid() -> bool:
	if not is_instance_valid(current_target):
		return false
	if current_target.get_instance_id() in _hit_ids:
		return false
	if "alive" in current_target and not current_target.alive:
		return false
	return true

func _on_body_entered(body):
	if not body.is_in_group("Enemy"):
		return
	if body.get_instance_id() in _hit_ids:
		return
	_hit_ids.append(body.get_instance_id())
	body.take_damage(int(round(_dmg)), global_position)
	Audio.play_sfx("hit")
	_hits += 1
	_dmg *= falloff
	if _hits >= max_hits:
		queue_free()
		return
	_retarget()
	if current_target == null:
		queue_free()

func _retarget():
	var best: Node2D = null
	var best_d := bounce_range
	for e in get_tree().get_nodes_in_group("Enemy"):
		if e.get_instance_id() in _hit_ids:
			continue
		var d := global_position.distance_to(e.global_position)
		if d < best_d:
			best_d = d
			best = e
	current_target = best
