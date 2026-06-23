extends Area2D

var value: int = 1
var speed: float = 0.0
var pull_target: Node2D = null

func start_magnet(player_node):
	if pull_target == null: # Only set it once
		pull_target = player_node
		speed = 150.0 # Start with a base speed so it doesn't lag behind

func _physics_process(delta):
	if pull_target:
		speed += 20.0
		global_position = global_position.move_toward(pull_target.global_position, speed * delta)

# This function name MUST match the signal connection exactly
func _on_body_entered(body):
	if body.is_in_group("Player") or body.name == "Player":
		if body.has_method("collect_cash"):
			body.collect_cash(value)
		if body.has_method("collect_xp"):
			body.collect_xp(5)
		Audio.play_chip()
		queue_free()
