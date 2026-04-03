# poker_chip.gd
extends Node2D

var value: int = 1
var speed: float = 0.0
var pull_target: Node2D = null

# magnet logic
func _physics_process(delta):
	if pull_target:
		speed += 20.0 # Accelerate as it gets closer
		global_position = global_position.move_toward(pull_target.global_position, speed * delta)

# setting player as pulling target
func start_magnet(player_node):
	pull_target = player_node

# start going towards player
func _on_pickup_area_body_entered(body):
	if body.is_in_group("Player"):
		body.collect_cash(value)
		body.collect_xp(5)
		queue_free()