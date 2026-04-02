extends CharacterBody2D

@export var speed: float = 100.0
var player: Node2D = null

func _ready():
	# When the enemy spawns, it shouts into the void to find the node in the "Player" group
	player = get_tree().get_first_node_in_group("Player")

func _physics_process(_delta):
	# If the player exists, run directly at them!
	if player != null:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		move_and_slide()