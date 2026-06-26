extends CanvasLayer

@onready
var master_slider: HSlider = $CenterContainer/PanelContainer/VBoxContainer/MasterRow/MasterSlider
@onready
var music_slider: HSlider = $CenterContainer/PanelContainer/VBoxContainer/MusicRow/MusicSlider
@onready var sfx_slider: HSlider = $CenterContainer/PanelContainer/VBoxContainer/SfxRow/SfxSlider
@onready var dev_mode_checkbox: CheckBox = $CenterContainer/PanelContainer/VBoxContainer/DevModeRow/DevModeCheckbox
@onready var fullscreen_checkbox: CheckBox = $CenterContainer/PanelContainer/VBoxContainer/FullscreenRow/FullscreenCheckbox
@onready var back_btn: Button = $CenterContainer/PanelContainer/VBoxContainer/BackBtn


func _ready():
	master_slider.value = Settings.master_volume
	music_slider.value = Settings.music_volume
	sfx_slider.value = Settings.sfx_volume
	dev_mode_checkbox.button_pressed = Settings.dev_mode_enabled
	fullscreen_checkbox.button_pressed = Settings.is_fullscreen

	master_slider.value_changed.connect(Settings.set_master_volume)
	music_slider.value_changed.connect(Settings.set_music_volume)
	sfx_slider.value_changed.connect(Settings.set_sfx_volume)
	dev_mode_checkbox.toggled.connect(_on_dev_mode_toggled)
	fullscreen_checkbox.toggled.connect(_on_fullscreen_toggled)

	back_btn.pressed.connect(_on_back_pressed)

func _on_dev_mode_toggled(toggled_on: bool):
	Settings.dev_mode_enabled = toggled_on
	Settings.save_settings()

func _on_fullscreen_toggled(toggled_on: bool):
	Settings.set_fullscreen(toggled_on)


func _on_back_pressed():
	queue_free()
