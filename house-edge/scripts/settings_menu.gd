extends CanvasLayer

@onready
var master_slider: HSlider = $CenterContainer/PanelContainer/VBoxContainer/MasterRow/MasterSlider
@onready
var music_slider: HSlider = $CenterContainer/PanelContainer/VBoxContainer/MusicRow/MusicSlider
@onready var sfx_slider: HSlider = $CenterContainer/PanelContainer/VBoxContainer/SfxRow/SfxSlider
@onready var back_btn: Button = $CenterContainer/PanelContainer/VBoxContainer/BackBtn


func _ready():
	master_slider.value = Settings.master_volume
	music_slider.value = Settings.music_volume
	sfx_slider.value = Settings.sfx_volume

	master_slider.value_changed.connect(Settings.set_master_volume)
	music_slider.value_changed.connect(Settings.set_music_volume)
	sfx_slider.value_changed.connect(Settings.set_sfx_volume)

	back_btn.pressed.connect(_on_back_pressed)


func _on_back_pressed():
	queue_free()
