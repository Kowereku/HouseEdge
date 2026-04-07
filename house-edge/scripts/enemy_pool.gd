extends Node

var mobster_scene = preload("res://scenes/mobster.tscn")
var pool: Array[CharacterBody2D] = []

func get_mobster(spawn_position: Vector2, player_node: CharacterBody2D) -> CharacterBody2D:
	var mobster: CharacterBody2D
	
	if pool.is_empty():
		# Pool is empty, we must create a new one
		mobster = mobster_scene.instantiate()
		# Add it to the current active scene safely
		get_tree().current_scene.call_deferred("add_child", mobster)
	else:
		# Grab a dead one from the pool
		mobster = pool.pop_back()
	
	# Reset the mobster's state
	mobster.global_position = spawn_position
	mobster.player = player_node
	
	# Wake it up
	mobster.show()
	mobster.set_process(true)
	mobster.set_physics_process(true)
	
	# Re-enable collisions safely
	mobster.get_node("CollisionPolygon2D").set_deferred("disabled", false)
	if mobster.has_node("SoftCollisionArea"):
		mobster.get_node("SoftCollisionArea").set_deferred("monitoring", true)
		
	return mobster

func return_mobster(mobster: CharacterBody2D):
	mobster.hide()
	mobster.set_process(false)
	mobster.set_physics_process(false)
	
	if mobster.has_node("CollisionPolygon2D"):
		mobster.get_node("CollisionPolygon2D").set_deferred("disabled", true)
	if mobster.has_node("SoftCollisionArea"):
		mobster.get_node("SoftCollisionArea").set_deferred("monitoring", false)
		
	pool.append(mobster)