extends CanvasLayer

const DEAD_TEXTURE_PATH := "res://assets/player_walk_frame1.png"
const FALLBACK_TEXTURE_PATH := "res://assets/player_walk_frame1.png"
const MAIN_MENU_PATH := "res://scenes/main_menu.tscn"

@onready var dealer_sprite: TextureRect = $CenterContainer/VBoxContainer/DealerSprite
@onready
var cash_label: Label = $CenterContainer/VBoxContainer/StatsPanel/Margin/VBox/CashRow/CashValue
@onready
var kills_label: Label = $CenterContainer/VBoxContainer/StatsPanel/Margin/VBox/KillsRow/KillsValue
@onready
var time_label: Label = $CenterContainer/VBoxContainer/StatsPanel/Margin/VBox/TimeRow/TimeValue
@onready
var level_label: Label = $CenterContainer/VBoxContainer/StatsPanel/Margin/VBox/LevelRow/LevelValue
@onready
var wave_label: Label = $CenterContainer/VBoxContainer/StatsPanel/Margin/VBox/WaveRow/WaveValue
@onready var menu_btn: Button = $CenterContainer/VBoxContainer/MenuBtn


func _ready():
	_load_dealer_sprite()
	cash_label.text = "$%d" % RunConfig.cash_collected
	kills_label.text = str(RunConfig.kills)
	time_label.text = RunConfig.format_duration()
	level_label.text = str(RunConfig.max_level_reached)
	wave_label.text = str(RunConfig.max_wave_reached)
	menu_btn.pressed.connect(_on_menu_pressed)


func _load_dealer_sprite():
	if ResourceLoader.exists(DEAD_TEXTURE_PATH):
		dealer_sprite.texture = load(DEAD_TEXTURE_PATH)
	else:
		dealer_sprite.texture = load(FALLBACK_TEXTURE_PATH)
		dealer_sprite.rotation = PI / 2
		dealer_sprite.modulate = Color(0.7, 0.5, 0.5, 1)


func _on_menu_pressed():
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
