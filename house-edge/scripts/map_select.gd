extends CanvasLayer

const CHARACTER_SELECT_PATH := "res://scenes/character_select.tscn"
const GAME_PATH := "res://scenes/main.tscn"

@onready
var play_btn: Button = $CenterContainer/VBoxContainer/GridContainer/Slot1/Margin/VBox/PlayBtn
@onready var back_btn: Button = $CenterContainer/VBoxContainer/BackBtn


func _ready():
	play_btn.pressed.connect(_on_play_pressed)
	back_btn.pressed.connect(_on_back_pressed)


func _on_play_pressed():
	RunConfig.selected_map = "default"
	get_tree().change_scene_to_file(GAME_PATH)


func _on_back_pressed():
	get_tree().change_scene_to_file(CHARACTER_SELECT_PATH)
