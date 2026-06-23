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
	_set_collisions(enemy, true)

	return enemy

func return_enemy(enemy: CharacterBody2D):
	# Put it to sleep
	enemy.hide()
	enemy.set_process(false)
	enemy.set_physics_process(false)
	
	# Disable collisions safely
	_set_collisions(enemy, false)

	# Put it back in the correct pool using the meta tag
	var path = enemy.get_meta("scene_path")
	pools[path].append(enemy)

# Toggle the enemy's actual (nested) collision nodes. Paths match mobster.tscn.
func _set_collisions(enemy: CharacterBody2D, enabled: bool):
	if enemy.has_node("WallCollision"):
		enemy.get_node("WallCollision").set_deferred("disabled", not enabled)
	if enemy.has_node("Pivot/Hurtbox/CollisionPolygon2D"):
		enemy.get_node("Pivot/Hurtbox/CollisionPolygon2D").set_deferred("disabled", not enabled)
	if enemy.has_node("Pivot/SoftCollisionArea"):
		enemy.get_node("Pivot/SoftCollisionArea").set_deferred("monitoring", enabled)
