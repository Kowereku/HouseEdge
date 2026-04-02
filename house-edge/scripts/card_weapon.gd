extends Node2D

@export var card_scene: PackedScene
@onready var shoot_timer = $ShootTimer

# We need to connect the Timer's timeout signal to this function!
func _on_shoot_timer_timeout():
	print("Timer ticked!") # This tells us if the timer is working at all

	var enemies = get_tree().get_nodes_in_group("Enemy")
	print("Enemies found: ", enemies.size()) # This tells us if it actually sees the mobsters

	if enemies.is_empty():
		return
    # ... rest of your code ...
    
	# Find the closest enemy
	var nearest_enemy = null
	var shortest_distance = INF
    
	for enemy in enemies:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < shortest_distance:
			shortest_distance = distance
			nearest_enemy = enemy
            
	if nearest_enemy != null:
		shoot_card(nearest_enemy)

func shoot_card(target):
	var card = card_scene.instantiate()
	# We add the card to the main game board, not the player. 
	# Otherwise, it would move whenever the player moves!
	get_tree().root.add_child(card) 

	card.global_position = global_position
	card.direction = global_position.direction_to(target.global_position)
	card.rotation = card.direction.angle() # Rotates the card to face the enemy