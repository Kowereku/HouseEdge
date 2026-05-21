extends CanvasLayer

const CHARACTER_SELECT_PATH := "res://scenes/character_select.tscn"
const SETTINGS_MENU_SCENE := preload("res://scenes/settings_menu.tscn")

@onready var play_btn: Button = $CenterContainer/PanelContainer/VBoxContainer/PlayBtn
@onready var settings_btn: Button = $CenterContainer/PanelContainer/VBoxContainer/SettingsBtn
@onready var quit_btn: Button = $CenterContainer/PanelContainer/VBoxContainer/QuitBtn

func _ready():
	play_btn.pressed.connect(_on_play_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	get_tree().change_scene_to_file(CHARACTER_SELECT_PATH)

func _on_settings_pressed():
	var menu = SETTINGS_MENU_SCENE.instantiate()
	add_child(menu)

func _on_quit_pressed():
	get_tree().quit()
