extends Node

const SAVE_PATH := "user://settings.cfg"

var master_volume: float = 1.0
var music_volume: float = 1.0
var sfx_volume: float = 1.0

var dev_mode_enabled: bool = false
var is_fullscreen: bool = false


func _ready():
	load_settings()
	apply_all()


func _apply_bus(bus_name: String, linear: float):
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return
	var clamped: float = clampf(linear, 0.0, 1.0)
	if clamped <= 0.0001:
		AudioServer.set_bus_mute(idx, true)
		AudioServer.set_bus_volume_db(idx, -80.0)
	else:
		AudioServer.set_bus_mute(idx, false)
		AudioServer.set_bus_volume_db(idx, linear_to_db(clamped))


func set_master_volume(v: float):
	master_volume = clampf(v, 0.0, 1.0)
	_apply_bus("Master", master_volume)
	save_settings()


func set_music_volume(v: float):
	music_volume = clampf(v, 0.0, 1.0)
	_apply_bus("Music", music_volume)
	save_settings()


func set_sfx_volume(v: float):
	sfx_volume = clampf(v, 0.0, 1.0)
	_apply_bus("SFX", sfx_volume)
	save_settings()


func apply_all():
	_apply_bus("Master", master_volume)
	_apply_bus("Music", music_volume)
	_apply_bus("SFX", sfx_volume)
	set_fullscreen(is_fullscreen)

func set_fullscreen(enabled: bool):
	is_fullscreen = enabled
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(1280, 720))
		# Optional: Center the window
		var screen_center = DisplayServer.screen_get_position() + DisplayServer.screen_get_size() / 2
		var window_size = DisplayServer.window_get_size()
		DisplayServer.window_set_position(screen_center - window_size / 2)
	save_settings()


func load_settings():
	var cfg := ConfigFile.new()
	var err := cfg.load(SAVE_PATH)
	if err != OK:
		return
	master_volume = cfg.get_value("audio", "master", master_volume)
	music_volume = cfg.get_value("audio", "music", music_volume)
	sfx_volume = cfg.get_value("audio", "sfx", sfx_volume)
	dev_mode_enabled = cfg.get_value("debug", "dev_mode", dev_mode_enabled)
	is_fullscreen = cfg.get_value("video", "fullscreen", is_fullscreen)


func save_settings():
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master", master_volume)
	cfg.set_value("audio", "music", music_volume)
	cfg.set_value("audio", "sfx", sfx_volume)
	cfg.set_value("debug", "dev_mode", dev_mode_enabled)
	cfg.set_value("video", "fullscreen", is_fullscreen)
	cfg.save(SAVE_PATH)
