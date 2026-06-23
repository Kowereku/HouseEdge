extends Node

var selected_character: String = "default"
var selected_map: String = "default"

var cash_collected: int = 0
var kills: int = 0
var max_level_reached: int = 1
var max_wave_reached: int = 1
var run_duration_ms: int = 0

var _run_start_ms: int = 0


func start_run():
	cash_collected = 0
	kills = 0
	max_level_reached = 1
	max_wave_reached = 1
	run_duration_ms = 0
	_run_start_ms = Time.get_ticks_msec()


func finalize_run():
	run_duration_ms = Time.get_ticks_msec() - _run_start_ms


func format_duration() -> String:
	var total_sec: int = int(run_duration_ms / 1000)
	var minutes: int = total_sec / 60
	var seconds: int = total_sec % 60
	return "%02d:%02d" % [minutes, seconds]
