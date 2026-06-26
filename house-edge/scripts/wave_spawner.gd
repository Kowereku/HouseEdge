extends Node

# Procedural wave director. The 15-minute stage is split into 15 one-minute
# waves; spawn rate, batch size, enemy mix, and enemy HP all ramp with the wave.

# How far past the visible screen edge enemies appear (pixels).
@export var spawn_margin: float = 80.0
# Legacy field kept so the scene's `waves = [...]` assignment still binds; unused.
@export var waves: Array[WaveEvent]

const MAX_ENEMIES := 130  # soft cap to protect performance
const WAVE_LENGTH := 60   # seconds per wave
const TOTAL_WAVES := 15

var mobster_scene = preload("res://scenes/mobster.tscn")
var grifter_scene = preload("res://scenes/grifter.tscn")
var gorilla_scene = preload("res://scenes/gorilla.tscn")

var player: CharacterBody2D
var seconds_survived: int = 0
var _wave: int = 0

func _ready():
	player = get_tree().get_first_node_in_group("Player")

func _on_spawn_timer_timeout():
	if not player:
		return
	seconds_survived += 1

	@warning_ignore("integer_division")
	var wave: int = clampi(seconds_survived / WAVE_LENGTH + 1, 1, TOTAL_WAVES)
	if wave != _wave:
		_wave = wave
		if wave > RunConfig.max_wave_reached:
			RunConfig.max_wave_reached = wave
		var hud = player.get_node_or_null("HUD")
		if hud and hud.has_method("update_wave"):
			hud.update_wave(wave, TOTAL_WAVES)

	# Spawn cadence: every 2s in early waves, every 1s from wave 5 on.
	var period: int = 2 if wave <= 4 else 1
	if seconds_survived % period != 0:
		return

	# Don't pile up beyond the soft cap.
	if get_tree().get_nodes_in_group("Enemy").size() >= MAX_ENEMIES:
		return

	var count: int = 1 + int(wave * 0.9)  # wave1~1 -> wave15~14
	var hp_mult: float = 1.0 + float(wave - 1) * 0.11  # 1.0 -> ~2.5
	for i in count:
		spawn_enemy(_pick_enemy(wave), hp_mult)

# Weighted enemy pick: grifters from wave 3, gorillas (rarer) from wave 5.
func _pick_enemy(wave: int) -> PackedScene:
	var w_mob: int = 6
	var w_grif: int = clampi(wave - 2, 0, 9)
	@warning_ignore("integer_division")
	var w_gor: int = clampi((wave - 3) / 2, 0, 5)
	var total := w_mob + w_grif + w_gor
	var r := randi() % total
	if r < w_mob:
		return mobster_scene
	if r < w_mob + w_grif:
		return grifter_scene
	return gorilla_scene

func spawn_enemy(scene: PackedScene, hp_mult: float = 1.0):
	# Spawn just outside the visible screen rectangle, in a random direction.
	var dir := Vector2.RIGHT.rotated(randf() * TAU)
	var half := Vector2(960.0, 540.0)
	var cam := get_viewport().get_camera_2d()
	var center := player.global_position
	if cam:
		half = (get_viewport().get_visible_rect().size / cam.zoom) * 0.5
		center = cam.get_screen_center_position()
	half += Vector2(spawn_margin, spawn_margin)
	var tx: float = half.x / maxf(absf(dir.x), 0.0001)
	var ty: float = half.y / maxf(absf(dir.y), 0.0001)
	var spawn_position := center + dir * minf(tx, ty)

	var enemy = EnemyPool.get_enemy(scene, spawn_position, player)
	if enemy and enemy.has_method("scale_hp"):
		enemy.scale_hp(hp_mult)
