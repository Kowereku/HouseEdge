extends CharacterBody2D

@export var speed: float = 100.0
var player: Node2D = null
var health: int = 10
var chip_scene = preload("res://scenes/poker_chip.tscn")

func _ready():
	# When the enemy spawns, it shouts into the void to find the node in the "Player" group
	player = get_tree().get_first_node_in_group("Player")

func _physics_process(_delta):
	# If the player exists, run directly at them
	if player:
		# Calculate the direction to the player
		var direction = global_position.direction_to(player.global_position)
		
		# Move the enemy
		velocity = direction * speed
		move_and_slide()
		
		# --- FACING LOGIC ---
		# If the player is to the left (negative X direction)
		if direction.x < 0:
			$AnimatedSprite2D.flip_h = true  # Face left
		# If the player is to the right (positive X direction)
		elif direction.x > 0:
			$AnimatedSprite2D.flip_h = false # Face right

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		var chip = chip_scene.instantiate()
		get_tree().current_scene.call_deferred("add_child", chip)
		chip.global_position = global_position

		queue_free()
