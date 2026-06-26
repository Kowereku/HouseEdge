extends Node

var selected_character: String = "default"
var selected_map: String = "default"

var cash_collected: int = 0
var kills: int = 0
var max_level_reached: int = 1
var max_wave_reached: int = 1
var run_duration_ms: int = 0
var time_elapsed: float = 0.0
var score: int = 0
var gold_collected: int = 0
var is_invincible: bool = false

var _run_start_ms: int = 0


func start_run():
	cash_collected = 0
	kills = 0
	max_level_reached = 1
	max_wave_reached = 1
	run_duration_ms = 0
	time_elapsed = 0.0
	score = 0
	gold_collected = 0
	is_invincible = false
	_run_start_ms = Time.get_ticks_msec()


func finalize_run():
	run_duration_ms = Time.get_ticks_msec() - _run_start_ms
	MetaProgression.add_coins(gold_collected)


func format_duration() -> String:
	# Integer division is intentional here (truncating ms -> whole seconds/minutes).
	@warning_ignore("integer_division")
	var total_sec: int = run_duration_ms / 1000
	@warning_ignore("integer_division")
	var minutes: int = total_sec / 60
	var seconds: int = total_sec % 60
	return "%02d:%02d" % [minutes, seconds]
