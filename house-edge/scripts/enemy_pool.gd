extends Node

# Dictionary to hold multiple pools. Key = scene path, Value = Array of dead enemies
var pools: Dictionary = {}

# Drop all pooled references. Call when (re)starting a run, because pooled
# enemies belong to the gameplay scene and are freed when that scene unloads.
func clear():
	pools.clear()

func get_enemy(enemy_scene: PackedScene, spawn_position: Vector2, player_node: CharacterBody2D) -> CharacterBody2D:
	var path = enemy_scene.resource_path
	
	# If this enemy type doesn't have a pool yet, create one
	if not pools.has(path):
		pools[path] = []
		
	var enemy: CharacterBody2D = null
	var from_pool: bool = false

	# Pull a still-valid enemy from the pool. Skip any that were freed when a
	# previous run's scene was unloaded (the autoload outlives the scene).
	while enemy == null and not pools[path].is_empty():
		var candidate = pools[path].pop_back()
		if is_instance_valid(candidate):
			enemy = candidate
			from_pool = true

	if enemy == null:
		# Pool empty (or only held stale refs): instantiate a fresh one.
		enemy = enemy_scene.instantiate()
		# Add string to quickly identify its pool later when returning it
		enemy.set_meta("scene_path", path)
		get_tree().current_scene.call_deferred("add_child", enemy)

	# Reused enemies need their per-life state reset (alive flag, group, etc.).
	if from_pool and enemy.has_method("_on_pool_spawn"):
		enemy._on_pool_spawn()
	
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
