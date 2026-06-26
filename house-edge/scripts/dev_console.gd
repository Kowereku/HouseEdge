extends CanvasLayer

@onready var invincibility_check = $PanelContainer/VBoxContainer/InvincibilityCheck
@onready var enemy_option = $PanelContainer/VBoxContainer/SpawnRow/EnemyOption
@onready var upgrade_option = $PanelContainer/VBoxContainer/UpgradeRow/UpgradeOption

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_QUOTELEFT:
		if Settings.dev_mode_enabled:
			visible = !visible
			if visible:
				invincibility_check.button_pressed = RunConfig.is_invincible

func _on_speed_1x_pressed():
	Engine.time_scale = 1.0

func _on_speed_2x_pressed():
	Engine.time_scale = 2.0

func _on_speed_4x_pressed():
	Engine.time_scale = 4.0

func _on_speed_10x_pressed():
	Engine.time_scale = 10.0

func _on_invincible_toggled(toggled_on: bool):
	RunConfig.is_invincible = toggled_on

func _on_gold_pressed():
	MetaProgression.gold_coins += 1000
	RunConfig.gold_collected += 1000
	MetaProgression.save_data()

func _on_win_pressed():
	RunConfig.finalize_run()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/win.tscn")
	visible = false

func _on_lose_pressed():
	RunConfig.finalize_run()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	visible = false

func _on_spawn_pressed():
	var main = get_tree().current_scene
	var player = main.get_node_or_null("Player")
	if player:
		var enemy_scene: PackedScene = null
		match enemy_option.selected:
			0: enemy_scene = preload("res://scenes/mobster.tscn")
			1: enemy_scene = preload("res://scenes/gorilla.tscn")
			2: enemy_scene = preload("res://scenes/grifter.tscn")
		
		var offset = Vector2(randf_range(-200, 200), randf_range(-200, 200))
		EnemyPool.get_enemy(enemy_scene, player.global_position + offset, player)

func _on_upgrade_pressed():
	var main = get_tree().current_scene
	var player = main.get_node_or_null("Player")
	if player:
		var type = ""
		match upgrade_option.selected:
			0: type = "gun"
			1: type = "speed"
			2: type = "shoot"
			3: type = "magnet"
			4: type = "dice"
			5: type = "roulette"
			6: type = "regen"
			7: type = "vitality"
		player._apply_upgrade(type)
