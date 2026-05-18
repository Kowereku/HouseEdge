extends CharacterBody2D

var level_menu_scene = preload("res://scenes/level_up_menu.tscn")

@export var speed: float = 300.0
var cash: int = 0
var health: int = 100
var max_health: int = 100
var experience: int = 0
var level: int = 1
var xp_to_next_level: int = 5 
var is_invincible: bool = false

var added_damage: int = 0
var attack_speed_modifier: float = 1.0

@onready var hurtbox = $Pivot/Hurtbox
@onready var invincibility_timer = $InvincibilityTimer
@onready var hud = $HUD
@onready var shoot_timer = $Pivot/CardWeapon/ShootTimer

func _ready():
	hud.update_cash(cash)
	hud.update_health(health, max_health)
	hud.update_xp(experience)
	hud.update_level(level)

func _physics_process(_delta):
	# Movement Logic
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction * speed
	move_and_slide()

# --- ANIMATION & FACING LOGIC ---
	if input_direction != Vector2.ZERO:
		$Pivot/AnimatedSprite2D.play("run") 

		if input_direction.x < 0:
			$Pivot.scale.x = -1  # Mirrors everything inside Pivot
		elif input_direction.x > 0:
			$Pivot.scale.x = 1   # Returns to normal
			
	else:
		# Player is NOT moving. 
		$Pivot/AnimatedSprite2D.stop() # Freeze the animation
		$Pivot/AnimatedSprite2D.frame = 0 # Force him to stand on the "idle" frame
	
	# Damage Logic
	if not is_invincible:
		var overlapping_bodies = hurtbox.get_overlapping_bodies()
		for body in overlapping_bodies:
			if body.is_in_group("Enemy"):
				take_damage()
				break 

func take_damage():
	health -= 10
	hud.update_health(health, max_health)
	print("Ouch! HP left: ", health)
	
	if health <= 0:
		print("GAME OVER!")
		get_tree().paused = true 
	else:
		is_invincible = true
		invincibility_timer.start()

func _on_invincibility_timer_timeout():
	is_invincible = false

func collect_cash(amount: int):
	cash += amount
	hud.update_cash(cash)

func collect_xp(amount: int):
	experience += amount
	hud.update_xp(experience)
	
	if experience >= xp_to_next_level:
		level_up()
		
# level up reseting exp and incresing treshold
func level_up():
	experience -= xp_to_next_level
	level += 1
	xp_to_next_level = int(xp_to_next_level * 1.2) + 10
	
	get_tree().paused = true
	var menu = level_menu_scene.instantiate()
	add_child(menu)
	menu.choice_made.connect(_apply_upgrade)
	
	hud.update_level(level)

# applying upgrades from level up
# (shoot timer is NOT working)
func _apply_upgrade(type):
	match type:
		"damage":
			added_damage += 5
			print("Damage upgrade chosen! New damage bonus: ", added_damage)
		"speed":
			speed += 50
			print("Speed upgrade chosen! New speed: ", speed)
		"shoot":
			if shoot_timer:
				shoot_timer.wait_time *= 0.8 
				print("Shoot upgrade! New wait time: ", shoot_timer.wait_time)
		"magnet":
			if has_node("MagnetRadius/CollisionShape2D"):
				$MagnetRadius/CollisionShape2D.shape.radius += 50.0
				print("Magnet upgrade! New radius: ", $MagnetRadius/CollisionShape2D.shape.radius)
		"regen":
			max_health += 20
			health = max_health 
			hud.update_health(health, max_health)
			print("Regen upgrade! Max health: ", max_health)


#debug func

func _on_debug_timer_timeout():
	print("--- PLAYER STATS CHECK ---")
	print("Level: ", level)
	print("Current HP: ", health, "/", max_health)
	print("Movement Speed: ", speed)
	print("Damage Bonus: +", added_damage)
	
	if shoot_timer:
		print("Attack Speed (Timer Interval): ", shoot_timer.wait_time)
	
	if has_node("MagnetRadius/CollisionShape2D"):
		var magnet_shape = $MagnetRadius/CollisionShape2D.shape
		if magnet_shape is CircleShape2D:
			print("Magnet Radius: ", magnet_shape.radius)
	
	print("--------------------------")


func _on_magnet_radius_area_entered(area):
	print("Magnet area detected: ", area.name)
	if area.has_method("start_magnet"):
		area.start_magnet(self)
