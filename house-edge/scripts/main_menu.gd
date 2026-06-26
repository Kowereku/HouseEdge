extends CanvasLayer

const CHARACTER_SELECT_PATH := "res://scenes/character_select.tscn"
const SETTINGS_MENU_SCENE := preload("res://scenes/settings_menu.tscn")
const META_SHOP_PATH := "res://scenes/meta_shop.tscn"

@onready var play_btn: Button = $CenterContainer/PanelContainer/VBoxContainer/PlayBtn
@onready var upgrades_btn: Button = $CenterContainer/PanelContainer/VBoxContainer/UpgradesBtn
@onready var settings_btn: Button = $CenterContainer/PanelContainer/VBoxContainer/SettingsBtn
@onready var quit_btn: Button = $CenterContainer/PanelContainer/VBoxContainer/QuitBtn


func _ready():
	get_tree().paused = false
	play_btn.pressed.connect(_on_play_pressed)
	upgrades_btn.pressed.connect(_on_upgrades_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)


func _on_play_pressed():
	get_tree().change_scene_to_file(CHARACTER_SELECT_PATH)


func _on_upgrades_pressed():
	get_tree().change_scene_to_file(META_SHOP_PATH)


func _on_settings_pressed():
	var menu = SETTINGS_MENU_SCENE.instantiate()
	add_child(menu)


func _on_quit_pressed():
	get_tree().quit()
