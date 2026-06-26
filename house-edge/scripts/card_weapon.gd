extends Node2D

@export var card_scene: PackedScene
@onready var shoot_timer = $ShootTimer


func _on_shoot_timer_timeout():
	var enemies = get_tree().get_nodes_in_group("Enemy")
	if enemies.is_empty():
		return

	# Only target enemies currently visible on screen.
	var view = _visible_world_rect()

	# Find the closest on-screen enemy
	var nearest_enemy = null
	var shortest_distance = INF
	for enemy in enemies:
		if view != null and not view.has_point(enemy.global_position):
			continue
		var distance = global_position.distance_to(enemy.global_position)
		if distance < shortest_distance:
			shortest_distance = distance
			nearest_enemy = enemy

	# No enemy on screen -> hold fire.
	if nearest_enemy != null:
		shoot_card(nearest_enemy)

func _visible_world_rect():
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return null
	var size: Vector2 = get_viewport().get_visible_rect().size / cam.zoom
	return Rect2(cam.get_screen_center_position() - size * 0.5, size)


func shoot_card(target):
	var card = card_scene.instantiate()
	# Basic starter weapon: flat damage (weapon upgrades come from the slot now).
	card.damage = 6

	# We add the card to the main game board
	get_tree().root.add_child(card)

	card.global_position = global_position
	# Calculate direction
	var direction = global_position.direction_to(target.global_position)
	card.direction = direction
	card.rotation = direction.angle() + deg_to_rad(90)  # Rotate card to face the target

	Audio.play_sfx("shoot")
