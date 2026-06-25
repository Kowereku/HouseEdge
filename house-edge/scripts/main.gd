extends Node2D

@onready var game_timer = $GameTimer
@onready var time_label = $CanvasLayerMain/Label

func _ready():
	game_timer.wait_time = 20
	game_timer.start()

func _process(_delta):
	var time_left = int(game_timer.time_left)
	
	var minutes = time_left / 60
	var seconds = time_left % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]

func _on_game_timer_timeout():
	trigger_auto_win()

func trigger_auto_win():
	get_tree().paused = true
	get_tree().change_scene_to_file("res://scenes/win.tscn")
