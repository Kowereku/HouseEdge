extends Node

# How far past the visible screen edge enemies appear (pixels).
@export var spawn_margin: float = 80.0
@export var waves: Array[WaveEvent]

var player: CharacterBody2D
var seconds_survived: int = 0


func _ready():
	# Find the player once when the spawner loads
	player = get_tree().get_first_node_in_group("Player")


func _on_spawn_timer_timeout():
	# Don't spawn if the player is dead/missing
	if not player:
		return

	seconds_survived += 1

	# Track current wave number by index of latest wave whose start_time has been reached
	for i in range(waves.size()):
		if seconds_survived >= waves[i].start_time:
			var wave_num: int = i + 1
			if wave_num > RunConfig.max_wave_reached:
				RunConfig.max_wave_reached = wave_num

	# Check every wave in our array
	for wave in waves:
		# Is this wave currently active?
		if seconds_survived >= wave.start_time and seconds_survived <= wave.end_time:
			# Is it time to spawn based on its interval?
			# (Modulo math prevents divide by zero issues and spaces spawns)
			if wave.spawn_interval > 0 and seconds_survived % wave.spawn_interval == 0:
				# Spawn the correct amount
				for i in range(wave.amount_per_spawn):
					# Ensure we actually have an enemy scene assigned to prevent crashes
					if wave.enemy_scene:
						spawn_enemy(wave.enemy_scene)


func spawn_enemy(scene: PackedScene):
	# Spawn just outside the visible screen rectangle, in a random direction.
	var dir := Vector2.RIGHT.rotated(randf() * TAU)

	# Half-size of the visible world area (viewport / camera zoom), plus margin.
	var half := Vector2(960.0, 540.0)  # fallback if no camera
	var cam := get_viewport().get_camera_2d()
	var center := player.global_position
	if cam:
		half = (get_viewport().get_visible_rect().size / cam.zoom) * 0.5
		center = cam.get_screen_center_position()
	half += Vector2(spawn_margin, spawn_margin)

	# Distance from center to the rectangle edge along dir, then step just past it.
	var tx: float = half.x / maxf(absf(dir.x), 0.0001)
	var ty: float = half.y / maxf(absf(dir.y), 0.0001)
	var spawn_position := center + dir * minf(tx, ty)

	# Fetch an enemy from our Autoload pool
	EnemyPool.get_enemy(scene, spawn_position, player)
