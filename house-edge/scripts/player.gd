extends CharacterBody2D

var level_menu_scene = preload("res://scenes/slot_machine.tscn")

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

# Passive health regeneration (HP per second). Baseline trickle; upgrades add more.
var health_regen: float = 0.2
var _regen_accumulator: float = 0.0

@onready var hurtbox = $Pivot/Hurtbox
@onready var invincibility_timer = $InvincibilityTimer
@onready var hud = $HUD
@onready var shoot_timer = $Pivot/CardWeapon/ShootTimer
@onready var camera = $Camera2D
@onready var health_bar = $HealthBar

# Screen shake: current strength (px), decays to zero each frame.
const SHAKE_DECAY: float = 28.0
var _shake: float = 0.0

func _ready():
	# Top-down movement: float in all directions equally (not grounded).
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	# Keep processing while the tree is paused so the pause key can also CLOSE
	# the menu (movement / regen / damage are gated while paused, see below).
	process_mode = Node.PROCESS_MODE_ALWAYS
	# ...but the rest of the player (weapon + ShootTimer, sprite, hurtbox) must
	# still pause, otherwise cards keep firing while the menu is open.
	$Pivot.process_mode = Node.PROCESS_MODE_PAUSABLE
	$InvincibilityTimer.process_mode = Node.PROCESS_MODE_PAUSABLE
	# Pooled enemies belong to the previous run's scene; drop stale references.
	EnemyPool.clear()
	RunConfig.start_run()
	hud.update_cash(cash)
	_update_health_bar()
	hud.update_xp(experience, xp_to_next_level)
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
			if not body.is_in_group("Enemy"):
				continue
			# Ignore enemies that are dead but still briefly in the overlap list
			# (collision is disabled with set_deferred, so it lags a frame or two).
			if "alive" in body and not body.alive:
				continue
			# Guard against a stale overlap entry: a killed enemy that the pool
			# instantly recycled is re-marked alive and teleported far away, yet
			# lingers one physics frame in the overlap list. Its transform is
			# already updated, so an actual-distance check rejects it.
			if global_position.distance_to(body.global_position) > 150.0:
				continue
			take_damage()
			break

func _process(delta):
	if _shake > 0.0:
		_shake = maxf(_shake - SHAKE_DECAY * delta, 0.0)
		camera.offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _shake
	elif camera.offset != Vector2.ZERO:
		camera.offset = Vector2.ZERO

func add_shake(amount: float):
	_shake = maxf(_shake, amount)

# World-space health bar above the player. Hidden when at full HP.
func _update_health_bar():
	if not is_instance_valid(health_bar):
		return
	health_bar.max_value = max_health
	health_bar.value = health
	health_bar.visible = health < max_health

func _process_regen(delta):
	if health_regen <= 0.0 or health >= max_health:
		return
	_regen_accumulator += health_regen * delta
	if _regen_accumulator >= 1.0:
		var heal = int(_regen_accumulator)
		_regen_accumulator -= heal
		health = min(health + heal, max_health)
		_update_health_bar()

func take_damage():
	health -= 10
	_update_health_bar()
	Audio.play_sfx("hurt")
	add_shake(9.0)
	var spr = $Pivot/AnimatedSprite2D
	spr.modulate = Color(1.0, 0.4, 0.4)
	create_tween().tween_property(spr, "modulate", Color.WHITE, 0.25)

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

# Spend collected chips (used by the slot machine for rerolls).
func spend_cash(amount: int):
	cash = max(0, cash - amount)
	hud.update_cash(cash)

func collect_xp(amount: int):
	experience += amount
	hud.update_xp(experience, xp_to_next_level)

	if experience >= xp_to_next_level:
		level_up()

# level up reseting exp and incresing treshold
func level_up():
	experience -= xp_to_next_level
	level += 1
	RunConfig.max_level_reached = level
	xp_to_next_level = int(xp_to_next_level * 1.2) + 10
	Audio.play_sfx("level_up")
	hud.update_xp(experience, xp_to_next_level)

	get_tree().paused = true
	# The slot machine reads/applies upgrades on this player via get_parent().
	var menu = level_menu_scene.instantiate()
	add_child(menu)

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
			_update_health_bar()
		"vitality":
			max_health += 25
			health = min(health + 25, max_health)
			_update_health_bar()
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
					_update_health_bar()


func _on_magnet_radius_area_entered(area):
	if area.has_method("start_magnet"):
		area.start_magnet(self)

func _toggle_pause():
	var pause_menu = get_parent().get_node_or_null("PauseMenu")
	if pause_menu and pause_menu.has_method("toggle"):
		pause_menu.toggle()
