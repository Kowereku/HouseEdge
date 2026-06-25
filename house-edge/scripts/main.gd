extends Node2D

# Stage length. The GameTimer counts DOWN from this; at 0 the stage is won.
const STAGE_SECONDS := 900  # 15 minutes
const DIGIT_H := 64.0
const DIGIT_AR := 183.0 / 199.0  # digit sprite aspect (w/h)
const COLON_AR := 91.0 / 199.0

@onready var game_timer = $GameTimer

var _glyphs: Dictionary = {}
var _slots: Array = []
var _last_text := ""

func _ready():
	game_timer.wait_time = STAGE_SECONDS
	game_timer.start()
	# Hide the old plain text label; we draw the timer with sprites instead.
	if has_node("CanvasLayerMain/Label"):
		$CanvasLayerMain/Label.visible = false
	_build_timer_display()

func _build_timer_display():
	for c in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "colon"]:
		var p := "res://assets/digits/digit_%s.png" % c
		if ResourceLoader.exists(p):
			_glyphs[c] = load(p)

	var dw := DIGIT_H * DIGIT_AR
	var cw := DIGIT_H * COLON_AR
	var gap := 2.0
	var widths := [dw, dw, cw, dw, dw]  # M M : S S
	var total := gap * (widths.size() - 1)
	for w in widths:
		total += w

	var vp := get_viewport().get_visible_rect().size
	var x := (vp.x - total) * 0.5
	var y := 10.0
	var layer := $CanvasLayerMain
	for i in widths.size():
		var slot := TextureRect.new()
		slot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		slot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.position = Vector2(x, y)
		slot.size = Vector2(widths[i], DIGIT_H)
		layer.add_child(slot)
		_slots.append(slot)
		x += widths[i] + gap

func _process(_delta):
	var t := int(ceil(game_timer.time_left))
	if t < 0:
		t = 0
	@warning_ignore("integer_division")
	var text := "%02d:%02d" % [t / 60, t % 60]
	if text == _last_text:
		return
	_last_text = text
	for i in text.length():
		if i >= _slots.size():
			break
		var ch := text[i]
		var key := "colon" if ch == ":" else ch
		if _glyphs.has(key):
			_slots[i].texture = _glyphs[key]

func _on_game_timer_timeout():
	trigger_auto_win()

func trigger_auto_win():
	RunConfig.finalize_run()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/win.tscn")
