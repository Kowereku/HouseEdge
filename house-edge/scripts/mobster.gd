extends CharacterBody2D

@export var speed: float = 100.0
@export var separation_force: float = 40.0  # Adjust this to change how hard they push apart
@export var max_health: int = 12
@export var contact_damage: int = 8  # damage dealt to the player on touch

var player: CharacterBody2D
var is_on_screen: bool = true

var health: int = 10
var alive: bool = true
var _base_max_health: int = 0  # captured lazily so wave-scaling never compounds

# Scale this enemy's HP for the current wave. Uses the scene's base value so
# repeated pool reuse doesn't stack the multiplier.
func scale_hp(mult: float):
	if _base_max_health <= 0:
		_base_max_health = max_health
	max_health = maxi(1, int(round(_base_max_health * mult)))
	health = max_health

# Knockback applied on hit, decaying back to zero.
const KNOCKBACK_FORCE: float = 260.0
const KNOCKBACK_DECAY: float = 900.0
var knockback: Vector2 = Vector2.ZERO

# Cached separation push, recomputed every other physics frame to cut the cost
# of overlap queries when many enemies are on screen.
var _push_vector: Vector2 = Vector2.ZERO

var chip_scene = preload("res://scenes/poker_chip.tscn")
var damage_number_scene = preload("res://scenes/damage_number.tscn")
var hit_spark_scene = preload("res://scenes/hit_spark.tscn")

@onready var sprite = $Pivot/AnimatedSprite2D
@onready var soft_collision_area = $Pivot/SoftCollisionArea
@onready var pivot = $Pivot
@onready var wall_collision = $WallCollision
@onready var hurtbox = $Pivot/Hurtbox
@onready var hurtbox_collision = $Pivot/Hurtbox/CollisionPolygon2D


func _ready():
	# Top-down movement: floating mode moves equally in all directions
	# (grounded mode makes vertical movement asymmetric).
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	health = max_health  # set after @export values are applied
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
				$Pivot.scale.x = 1  # Returns to normal

		# --- MOVEMENT & SEPARATION ---
		if is_on_screen:
			# Recompute separation only every other physics frame (staggered per
			# enemy) — overlap queries are the main cost when crowds form.
			if soft_collision_area.monitoring and (Engine.get_physics_frames() + (get_instance_id() % 2)) % 2 == 0:
				var push := Vector2.ZERO
				for area in soft_collision_area.get_overlapping_areas():
					if area != soft_collision_area:
						push += area.global_position.direction_to(global_position)
				_push_vector = push.normalized() if push != Vector2.ZERO else Vector2.ZERO

			var target_velocity = (direction * speed) + (_push_vector * separation_force)
			velocity = target_velocity.limit_length(speed * 1.5) + knockback
			move_and_slide()
			knockback = knockback.move_toward(Vector2.ZERO, KNOCKBACK_DECAY * delta)
		else:
			# OFF-SCREEN OPTIMIZATION: Direct translation, no physics math
			global_position += direction * speed * delta


func take_damage(amount: int, source_position: Vector2 = Vector2.INF):
	# Ignore hits once already dead — prevents "ghost damage" on a pooled enemy
	# (deferred collision disable leaves a frame where it can still be hit).
	if not alive:
		return

	health -= amount
	_spawn_damage_number(amount)

	if health <= 0:
		# Mark dead and leave the Enemy group immediately so the weapon stops
		# targeting it and nothing can hit it again before it returns to the pool.
		alive = false
		remove_from_group("Enemy")
		RunConfig.kills += 1
		Audio.play_sfx("enemy_death")
		_spawn_hit_spark()

		var chip = chip_scene.instantiate()
		get_tree().current_scene.call_deferred("add_child", chip)
		chip.global_position = global_position

		# POOLING: Return to pool instead of queue_free()
		knockback = Vector2.ZERO
		EnemyPool.return_enemy(self)

		# Reset health for the next time this enemy is pulled from the pool
		health = max_health
	else:
		_flash()
		if source_position != Vector2.INF:
			knockback = source_position.direction_to(global_position) * KNOCKBACK_FORCE

# Called by EnemyPool when this enemy is reused from the pool.
func _on_pool_spawn():
	alive = true
	health = max_health
	knockback = Vector2.ZERO
	if not is_in_group("Enemy"):
		add_to_group("Enemy")

func _flash():
	sprite.modulate = Color(1.7, 1.7, 1.9)
	create_tween().tween_property(sprite, "modulate", Color.WHITE, 0.14)

func _spawn_damage_number(amount: int):
	# Cap concurrent damage numbers so heavy fire doesn't flood the scene.
	if get_tree().get_nodes_in_group("dmg_number").size() >= 45:
		return
	var dn = damage_number_scene.instantiate()
	get_tree().current_scene.add_child(dn)
	dn.setup(amount, global_position)

func _spawn_hit_spark():
	var spark = hit_spark_scene.instantiate()
	get_tree().current_scene.add_child(spark)
	spark.global_position = global_position


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	is_on_screen = true
	if not is_node_ready():
		await ready

	# Enable both types of collision
	wall_collision.set_deferred("disabled", false)
	hurtbox_collision.set_deferred("disabled", false)
	soft_collision_area.set_deferred("monitoring", true)
	sprite.modulate = Color.WHITE
	sprite.play("default")


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	is_on_screen = false
	if not is_node_ready():
		await ready

	# Disable both so they don't lag the game off-screen
	wall_collision.set_deferred("disabled", true)
	hurtbox_collision.set_deferred("disabled", true)
	soft_collision_area.set_deferred("monitoring", false)
	sprite.stop()
