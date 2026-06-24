extends CanvasLayer

# In-game pause overlay. Toggled with the "pause" action (Esc).
# The node runs with process_mode = ALWAYS so it can catch the toggle
# whether the game is running or already paused.

const MAIN_MENU_PATH := "res://scenes/main_menu.tscn"
const SETTINGS_MENU_SCENE := preload("res://scenes/settings_menu.tscn")

var is_open: bool = false
var _settings_instance: CanvasLayer = null

@onready var resume_btn: Button = $CenterContainer/PanelContainer/VBoxContainer/ResumeBtn
@onready var settings_btn: Button = $CenterContainer/PanelContainer/VBoxContainer/SettingsBtn
@onready var menu_btn: Button = $CenterContainer/PanelContainer/VBoxContainer/MenuBtn

func _ready():
	visible = false
	resume_btn.pressed.connect(_on_resume_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	menu_btn.pressed.connect(_on_menu_pressed)

# Called by the player when the pause key is pressed.
func toggle():
	if is_open:
		_resume()
	elif not get_tree().paused:
		# Don't open over another overlay that already paused (e.g. level-up menu).
		_open()

func _open():
	is_open = true
	get_tree().paused = true
	visible = true
	resume_btn.grab_focus()

func _resume():
	# If the settings sub-overlay is open, close it first.
	if is_instance_valid(_settings_instance):
		_settings_instance.queue_free()
		_settings_instance = null
	is_open = false
	visible = false
	get_tree().paused = false

func _on_resume_pressed():
	_resume()

func _on_settings_pressed():
	if is_instance_valid(_settings_instance):
		return
	_settings_instance = SETTINGS_MENU_SCENE.instantiate()
	add_child(_settings_instance)

func _on_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
