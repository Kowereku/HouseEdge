extends Node

# Dictionary to hold multiple pools. Key = scene path, Value = Array of dead enemies
var pools: Dictionary = {} 

func get_enemy(enemy_scene: PackedScene, spawn_position: Vector2, player_node: CharacterBody2D) -> CharacterBody2D:
	var path = enemy_scene.resource_path
	
	# If this enemy type doesn't have a pool yet, create one
	if not pools.has(path):
		pools[path] = []
		
	var enemy: CharacterBody2D
	
	if pools[path].is_empty():
		# Pool is empty, instantiate a new one
		enemy = enemy_scene.instantiate()
		# Add string to quickly identify its pool later when returning it
		enemy.set_meta("scene_path", path) 
		get_tree().current_scene.call_deferred("add_child", enemy)
	else:
		# Grab a dead one from the pool
		enemy = pools[path].pop_back()
	
	# Reset the enemy's state
	enemy.global_position = spawn_position
	enemy.player = player_node
	
	# Wake it up
	enemy.show()
	enemy.set_process(true)
	enemy.set_physics_process(true)
	
	# Re-enable collisions safely
	if enemy.has_node("CollisionPolygon2D"):
		enemy.get_node("CollisionPolygon2D").set_deferred("disabled", false)
	if enemy.has_node("SoftCollisionArea"):
		enemy.get_node("SoftCollisionArea").set_deferred("monitoring", true)
		
	return enemy

func return_enemy(enemy: CharacterBody2D):
	# Put it to sleep
	enemy.hide()
	enemy.set_process(false)
	enemy.set_physics_process(false)
	
	# Disable collisions safely
	if enemy.has_node("CollisionPolygon2D"):
		enemy.get_node("CollisionPolygon2D").set_deferred("disabled", true)
	if enemy.has_node("SoftCollisionArea"):
		enemy.get_node("SoftCollisionArea").set_deferred("monitoring", false)
		
	# Put it back in the correct pool using the meta tag
	var path = enemy.get_meta("scene_path")
	pools[path].append(enemy)
