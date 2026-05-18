extends Node

@export var spawn_radius: float = 1250.0 
@export var waves: Array[WaveEvent] 

var player: CharacterBody2D
var seconds_survived: int = 0

func _ready():
	# Find the player once when the spawner loads
	player = get_tree().get_first_node_in_group("Player")

func _on_spawn_timer_timeout():
	# Don't spawn if the player is dead/missing
	if not player:
		return
		
	seconds_survived += 1
	
	# Check every wave in our array
	for wave in waves:
		# Is this wave currently active?
		if seconds_survived >= wave.start_time and seconds_survived <= wave.end_time:
			
			# Is it time to spawn based on its interval? 
			# (Modulo math prevents divide by zero issues and spaces spawns)
			if wave.spawn_interval > 0 and seconds_survived % wave.spawn_interval == 0:
				
				# Spawn the correct amount
				for i in range(wave.amount_per_spawn):
					# Ensure we actually have an enemy scene assigned to prevent crashes
					if wave.enemy_scene:
						spawn_enemy(wave.enemy_scene)

func spawn_enemy(scene: PackedScene):
	# Pick a random angle in a full circle (TAU is 2 * PI)
	var random_angle = randf() * TAU
	
	# Create a direction vector pointing at that angle
	var spawn_direction = Vector2.RIGHT.rotated(random_angle)
	
	# Multiply direction by radius and add player's position to center it around them
	var spawn_position = player.global_position + (spawn_direction * spawn_radius)
	
	# Fetch an enemy from our Autoload pool
	EnemyPool.get_enemy(scene, spawn_position, player)

