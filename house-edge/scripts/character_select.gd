extends CanvasLayer

const MAIN_MENU_PATH := "res://scenes/main_menu.tscn"
const MAP_SELECT_PATH := "res://scenes/map_select.tscn"

@onready var select_btn: Button = $CenterContainer/VBoxContainer/GridContainer/Slot1/Margin/VBox/SelectBtn
@onready var back_btn: Button = $CenterContainer/VBoxContainer/BackBtn

func _ready():
	select_btn.pressed.connect(_on_select_pressed)
	back_btn.pressed.connect(_on_back_pressed)

func _on_select_pressed():
	RunConfig.selected_character = "default"
	get_tree().change_scene_to_file(MAP_SELECT_PATH)

func _on_back_pressed():
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
