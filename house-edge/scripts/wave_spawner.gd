extends Node

@export var spawn_radius: float = 1250.0 # Full hd resolution calculated

var player: CharacterBody2D

func _ready():
	# Find the player once when the spawner loads
	player = get_tree().get_first_node_in_group("Player")

func _on_spawn_timer_timeout():
	# Don't spawn if the player is dead/missing
	if not player:
		return
		
	# Pick a random angle in a full circle (TAU is 2 * PI)
	var random_angle = randf() * TAU
	
	# Create a direction vector pointing at that angle
	var spawn_direction = Vector2.RIGHT.rotated(random_angle)
	
	# Multiply direction by radius and add player's position to center it around them
	var spawn_position = player.global_position + (spawn_direction * spawn_radius)
	
	# Fetch a mobster from our Autoload pool
	EnemyPool.get_mobster(spawn_position, player)
