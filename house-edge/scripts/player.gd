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

# Passive health regeneration (HP per second). 0 = no regen.
var health_regen: float = 0.0
var _regen_accumulator: float = 0.0

@onready var hurtbox = $Pivot/Hurtbox
@onready var invincibility_timer = $InvincibilityTimer
@onready var hud = $HUD
@onready var shoot_timer = $Pivot/CardWeapon/ShootTimer

func _ready():
	# Keep processing while the tree is paused so the pause key can also CLOSE
	# the menu (movement / regen / damage are gated while paused, see below).
	process_mode = Node.PROCESS_MODE_ALWAYS
	# ...but the rest of the player (weapon + ShootTimer, sprite, hurtbox) must
	# still pause, otherwise cards keep firing while the menu is open.
	$Pivot.process_mode = Node.PROCESS_MODE_PAUSABLE
	$InvincibilityTimer.process_mode = Node.PROCESS_MODE_PAUSABLE
	RunConfig.start_run()
	hud.update_cash(cash)
	hud.update_health(health, max_health)
	hud.update_xp(experience)
	hud.update_level(level)

func _physics_process(delta):
	# Pause toggle — same Input-action polling that movement uses (this is the
	# code path we know receives input, since WASD works here).
	if Input.is_action_just_pressed("pause"):
		_toggle_pause()

	# While the menu is open the tree is paused: skip movement, regen, damage.
	if get_tree().paused:
		return

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

	# Passive regen logic
	_process_regen(delta)

	# Damage Logic
	if not is_invincible:
		var overlapping_bodies = hurtbox.get_overlapping_bodies()
		for body in overlapping_bodies:
			if body.is_in_group("Enemy"):
				take_damage()
				break

func _process_regen(delta):
	if health_regen <= 0.0 or health >= max_health:
		return
	_regen_accumulator += health_regen * delta
	if _regen_accumulator >= 1.0:
		var heal = int(_regen_accumulator)
		_regen_accumulator -= heal
		health = min(health + heal, max_health)
		hud.update_health(health, max_health)

func take_damage():
	health -= 10
	hud.update_health(health, max_health)
	Audio.play_sfx("hurt")

	if health <= 0:
		RunConfig.finalize_run()
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")
		return
	else:
		is_invincible = true
		invincibility_timer.start()

func _on_invincibility_timer_timeout():
	is_invincible = false

func collect_cash(amount: int):
	cash += amount
	RunConfig.cash_collected += amount
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
	RunConfig.max_level_reached = level
	xp_to_next_level = int(xp_to_next_level * 1.2) + 10
	Audio.play_sfx("level_up")

	get_tree().paused = true
	var menu = level_menu_scene.instantiate()
	add_child(menu)
	menu.choice_made.connect(_apply_upgrade)

	hud.update_level(level)

# applying upgrades from level up
func _apply_upgrade(type):
	match type:
		"damage":
			added_damage += 5
		"speed":
			speed += 50
		"shoot":
			if shoot_timer:
				shoot_timer.wait_time *= 0.8
		"magnet":
			if has_node("MagnetRadius/CollisionShape2D"):
				$MagnetRadius/CollisionShape2D.shape.radius += 50.0
		"regen":
			max_health += 20
			health_regen += 1.0
			health = max_health
			hud.update_health(health, max_health)
		"gamble":
			var possible_stats = ["damage", "speed", "shoot", "magnet", "regen"]
			var picked_stat = possible_stats.pick_random()
			match picked_stat:
				"damage":
					added_damage += 8
				"speed":
					speed += 75
				"shoot":
					if shoot_timer:
						shoot_timer.wait_time *= 0.7
				"magnet":
					if has_node("MagnetRadius/CollisionShape2D"):
						$MagnetRadius/CollisionShape2D.shape.radius += 75.0
				"regen":
					max_health += 30
					health_regen += 1.5
					health = max_health
					hud.update_health(health, max_health)


func _on_magnet_radius_area_entered(area):
	if area.has_method("start_magnet"):
		area.start_magnet(self)

func _toggle_pause():
	var pause_menu = get_parent().get_node_or_null("PauseMenu")
	if pause_menu and pause_menu.has_method("toggle"):
		pause_menu.toggle()
