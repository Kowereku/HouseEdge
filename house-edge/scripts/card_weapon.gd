extends Node2D

@export var card_scene: PackedScene
@onready var shoot_timer = $ShootTimer

func _on_shoot_timer_timeout(): # Shoots every second for now, but we will change this later with upgrades!
	var enemies = get_tree().get_nodes_in_group("Enemy")
	
	if enemies.is_empty():
		return
	
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
	
	# --- DAMAGE LOGIC START ---
	# We look at the Player script to find the 'added_damage' variable
	var player = get_parent() 
	if player and "added_damage" in player:
		# Base Damage (5) + Player's Bonus
		card.damage = 5 + player.added_damage
	# --- DAMAGE LOGIC END ---

	# We add the card to the main game board
	get_tree().root.add_child(card) 

	card.global_position = global_position
	# Calculate direction
	var direction = global_position.direction_to(target.global_position)
	card.direction = direction
	card.rotation = direction.angle() + deg_to_rad(90) # Rotate card to face the target