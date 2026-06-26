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

func _on_body_entered(body):
	if body.is_in_group("Player") or body.name == "Player":
		RunConfig.gold_collected += value
		Audio.play_chip() # using the same pickup sound
		queue_free()
