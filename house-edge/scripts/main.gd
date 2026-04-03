extends Node2D

# Load the enemy blueprint so the game has it ready
var mobster_scene = preload("res://scenes/mobster.tscn")

# Spawning enemy every second
func _on_wave_spawner_timeout():
	print("Enemies spawned!")
	var player = get_tree().get_first_node_in_group("Player")

	if player == null:
		return # Player is gone, stop spawning!

	var mob = mobster_scene.instantiate()
	
	# Calculate a random angle and push it 800 pixels away (need to adjust it to ALWAYS spawn outside the screen, even if the player has bigger screen)
	var random_angle = randf() * TAU 
	var spawn_distance = 800.0 

	var spawn_offset = Vector2.RIGHT.rotated(random_angle) * spawn_distance
	mob.global_position = player.global_position + spawn_offset

	add_child(mob)