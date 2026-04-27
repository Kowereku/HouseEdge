extends CharacterBody2D

@export var speed: float = 100.0
@export var separation_force: float = 40.0 # Adjust this to change how hard they push apart

var player: CharacterBody2D
var is_on_screen: bool = true

var max_health: int = 10
var health: int = max_health

var chip_scene = preload("res://scenes/poker_chip.tscn")

@onready var sprite = $Pivot/AnimatedSprite2D
@onready var soft_collision_area = $Pivot/SoftCollisionArea
@onready var pivot = $Pivot
@onready var wall_collision = $WallCollision 
@onready var hurtbox = $Pivot/Hurtbox
@onready var hurtbox_collision = $Pivot/Hurtbox/CollisionPolygon2D

func _ready():
	# If pulled from the pool, player might already be set. If not, grab it.
	if not player:
		player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta):
	# If the player exists, run directly at them
	if player:
		var direction = global_position.direction_to(player.global_position)
		
		# --- FACING LOGIC ---
		if direction.x != 0:
			if direction.x < 0:
				$Pivot.scale.x = -1  # Mirrors everything inside Pivot
			else:
				$Pivot.scale.x = 1   # Returns to normal
			
		# --- MOVEMENT & SEPARATION ---
		if is_on_screen:
			var push_vector = Vector2.ZERO
			var overlapping_areas = []
			if soft_collision_area.monitoring:
				overlapping_areas = soft_collision_area.get_overlapping_areas()
			
			for area in overlapping_areas:
				if area != soft_collision_area:
					# Push away from the overlapping area
					push_vector += area.global_position.direction_to(global_position)
			
			if push_vector != Vector2.ZERO:
				push_vector = push_vector.normalized()
				
			var target_velocity = (direction * speed) + (push_vector * separation_force)
			velocity = target_velocity.limit_length(speed * 1.5) # Limit max speed to prevent crazy physics
			move_and_slide()
		else:
			# OFF-SCREEN OPTIMIZATION: Direct translation, no physics math
				global_position += direction * speed * delta

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		var chip = chip_scene.instantiate()
		get_tree().current_scene.call_deferred("add_child", chip)
		chip.global_position = global_position
		
		# POOLING: Return to pool instead of queue_free()
		EnemyPool.return_enemy(self)
		
		# Reset health for the next time this enemy is pulled from the pool
		health = max_health

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	is_on_screen = true
	if not is_node_ready(): await ready

	# Enable both types of collision
	wall_collision.set_deferred("disabled", false)
	hurtbox_collision.set_deferred("disabled", false)
	soft_collision_area.set_deferred("monitoring", true)
	sprite.play("default") 

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	is_on_screen = false
	if not is_node_ready(): await ready

	# Disable both so they don't lag the game off-screen
	wall_collision.set_deferred("disabled", true)
	hurtbox_collision.set_deferred("disabled", true)
	soft_collision_area.set_deferred("monitoring", false)
	sprite.stop()
