extends CanvasLayer

# Slot-machine level-up. Pull the lever (click it) — three reels spin behind the
# machine, visible through the window holes, and stop one by one. The CENTER reel
# decides the upgrade; three-of-a-kind = jackpot (double). First spin free; rerolls
# cost escalating collected chips. Reroll/Accept sit in the lower slots.

const SYMBOLS := [
	{"type": "damage", "label": "+ DAMAGE"},
	{"type": "speed", "label": "+ MOVE SPEED"},
	{"type": "shoot", "label": "+ ATTACK SPEED"},
	{"type": "magnet", "label": "+ MAGNET RANGE"},
	{"type": "vitality", "label": "+ MAX HEALTH"},
	{"type": "regen", "label": "+ HEALTH REGEN"},
]

# Preloaded at game start (when the game scene preloads this scene) so the
# level-up menu opens instantly instead of decoding 14 PNGs on the spot.
const SYM_TEX := [
	preload("res://assets/sym_damage.png"),
	preload("res://assets/sym_speed.png"),
	preload("res://assets/sym_shoot.png"),
	preload("res://assets/sym_magnet.png"),
	preload("res://assets/sym_vitality.png"),
	preload("res://assets/sym_regen.png"),
]
const FRAME_TEX := [
	preload("res://assets/slot_f0.png"),
	preload("res://assets/slot_f1.png"),
	preload("res://assets/slot_f2.png"),
	preload("res://assets/slot_f3.png"),
	preload("res://assets/slot_f4.png"),
	preload("res://assets/slot_f5.png"),
	preload("res://assets/slot_f6.png"),
	preload("res://assets/slot_f7.png"),
]

const FRAME_COUNT := 8
const FRAME_W := 295.0
const FRAME_H := 369.0
const DISPLAY_H := 470.0
const LEVER_FPS := 18.0
# Body width in frame px (the machine minus the lever overhang on the right);
# used to center the body on screen rather than the whole sprite.
const BODY_W := 252.0
# Horizontal nudge (frame px) to visually center symbols in the windows.
const ICON_DX := 0.0
# All rects below are in frame pixels (x, y, w, h).
const REEL_RECTS := [[40, 105, 50, 89], [103, 105, 48, 89], [164, 105, 49, 89]]
const LEVER_RECT := [224, 48, 71, 210]
const ACCEPT_RECT := [79, 320, 96, 30]

var scale_f := DISPLAY_H / FRAME_H
var _textures: Array = []
var _frames: Array = []
var _reel_strips: Array = []
var _reel_dims: Array = []
var _reel_current: Array = []  # symbol index currently shown per reel

var machine: Control
var machine_img: TextureRect
var result_lbl: Label
var lever_hint: Label
var accept_btn: Button
var cash_lbl: Label

var reroll_count: int = 0
var spinning: bool = false
var has_result: bool = false
var pending_type: String = ""
var pending_label: String = ""
var jackpot: bool = false
var _lever_t: float = -1.0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_textures()
	_build_ui()
	_update_buttons()

func _load_textures():
	# Already preloaded as consts — just reference them (no disk decode here).
	_textures = SYM_TEX
	_frames = FRAME_TEX

func _process(delta):
	if _lever_t >= 0.0 and not _frames.is_empty():
		_lever_t += delta
		var idx := int(_lever_t * LEVER_FPS)
		if idx >= _frames.size():
			machine_img.texture = _frames[0]
			_lever_t = -1.0
		else:
			machine_img.texture = _frames[idx]

func _build_ui():
	var vp: Vector2 = get_viewport().get_visible_rect().size

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.72)
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	machine = Control.new()
	machine.size = Vector2(FRAME_W * scale_f, DISPLAY_H)
	# Center the BODY (lever overhangs right), not the whole sprite.
	machine.position = Vector2((vp.x - BODY_W * scale_f) * 0.5, (vp.y - machine.size.y) * 0.5 - 4)
	add_child(machine)

	# Reels first so they sit BEHIND the machine frame (shown through the holes).
	_build_reels()

	machine_img = TextureRect.new()
	machine_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	machine_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	machine_img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not _frames.is_empty():
		machine_img.texture = _frames[0]
	machine_img.position = Vector2.ZERO
	machine_img.size = machine.size
	machine.add_child(machine_img)

	# Clickable lever area (on top of the frame).
	var lever_btn := Control.new()
	lever_btn.position = Vector2(LEVER_RECT[0], LEVER_RECT[1]) * scale_f
	lever_btn.size = Vector2(LEVER_RECT[2], LEVER_RECT[3]) * scale_f
	lever_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	lever_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	lever_btn.gui_input.connect(_on_lever_input)
	lever_btn.mouse_entered.connect(func(): _on_lever_hover(true))
	lever_btn.mouse_exited.connect(func(): _on_lever_hover(false))
	machine.add_child(lever_btn)

	# Reroll suggestion: shown only while hovering the lever after a result.
	lever_hint = Label.new()
	lever_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	lever_hint.add_theme_font_size_override("font_size", 18)
	lever_hint.add_theme_color_override("font_color", Color(1, 0.9, 0.45))
	lever_hint.add_theme_color_override("font_outline_color", Color.BLACK)
	lever_hint.add_theme_constant_override("outline_size", 4)
	lever_hint.size = Vector2(210, 26)
	# Just to the RIGHT of the lever ball.
	lever_hint.position = machine.position + Vector2(294, 46) * scale_f
	lever_hint.hide()
	add_child(lever_hint)

	var title := Label.new()
	title.text = "PULL THE LEVER!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_outline_color", Color.BLACK)
	title.add_theme_constant_override("outline_size", 4)
	title.size = Vector2(vp.x, 36)
	title.position = Vector2(0, machine.position.y - 48)
	add_child(title)

	result_lbl = Label.new()
	result_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_lbl.add_theme_font_size_override("font_size", 24)
	result_lbl.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
	result_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	result_lbl.add_theme_constant_override("outline_size", 4)
	result_lbl.size = Vector2(vp.x, 32)
	result_lbl.position = Vector2(0, machine.position.y + machine.size.y + 2)
	add_child(result_lbl)

	cash_lbl = Label.new()
	cash_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cash_lbl.add_theme_font_size_override("font_size", 18)
	cash_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	cash_lbl.add_theme_constant_override("outline_size", 3)
	cash_lbl.size = Vector2(vp.x, 26)
	cash_lbl.position = Vector2(0, machine.position.y + machine.size.y + 34)
	add_child(cash_lbl)

	accept_btn = _make_slot_button("ACCEPT", ACCEPT_RECT)
	accept_btn.pressed.connect(_on_accept_pressed)

func _make_slot_button(text: String, rect: Array) -> Button:
	var b := Button.new()
	b.text = text
	b.flat = true
	b.position = machine.position + Vector2(rect[0], rect[1]) * scale_f
	b.size = Vector2(rect[2], rect[3]) * scale_f
	b.add_theme_color_override("font_color", Color(1, 0.85, 0.35))
	b.add_theme_color_override("font_hover_color", Color(1, 0.97, 0.6))
	b.add_theme_color_override("font_outline_color", Color.BLACK)
	b.add_theme_constant_override("outline_size", 4)
	b.add_theme_font_size_override("font_size", 19)
	b.hide()
	add_child(b)
	return b

func _build_reels():
	for i in REEL_RECTS.size():
		var rect = REEL_RECTS[i]
		var rw: float = rect[2] * scale_f
		var rh: float = rect[3] * scale_f
		var win := Control.new()
		win.clip_contents = true
		win.position = Vector2(rect[0] * scale_f, rect[1] * scale_f)
		win.size = Vector2(rw, rh)
		win.mouse_filter = Control.MOUSE_FILTER_IGNORE
		machine.add_child(win)
		var backdrop := ColorRect.new()
		backdrop.color = Color(0.02, 0.02, 0.05, 1)
		backdrop.size = Vector2(rw, rh)
		backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
		win.add_child(backdrop)
		var strip := Control.new()
		win.add_child(strip)
		_reel_strips.append(strip)
		_reel_dims.append([rw, rh])
		var first := randi() % _textures.size()
		_reel_current.append(first)
		_populate_strip(strip, rw, rh, [first])

func _populate_strip(strip: Control, rw: float, rh: float, indices: Array):
	for c in strip.get_children():
		c.queue_free()
	for k in indices.size():
		var sym := TextureRect.new()
		sym.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sym.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		sym.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sym.texture = _textures[indices[k]]
		sym.position = Vector2(ICON_DX * scale_f, k * rh)
		sym.size = Vector2(rw, rh)
		strip.add_child(sym)

func _spin_reel(i: int, target_index: int, duration: float, delay: float) -> Tween:
	var strip: Control = _reel_strips[i]
	var rw: float = _reel_dims[i][0]
	var rh: float = _reel_dims[i][1]
	var stop_slot: int = 18 + i * 3
	# Slot 0 keeps the CURRENTLY shown symbol so the reel doesn't visibly change
	# until the scroll actually starts (after the pre-spin delay).
	var indices: Array = [_reel_current[i]]
	for k in stop_slot - 1:
		indices.append(randi() % _textures.size())
	indices.append(target_index)
	for k in 2:
		indices.append(randi() % _textures.size())
	_populate_strip(strip, rw, rh, indices)
	strip.position.y = 0.0
	_reel_current[i] = target_index
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_interval(delay)
	tw.tween_property(strip, "position:y", -float(stop_slot) * rh, duration)
	return tw

func _on_lever_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_spin_pressed()

func _do_spin():
	if spinning:
		return
	spinning = true
	has_result = false
	Audio.play_sfx("click")
	_lever_t = 0.0
	var center := randi() % _textures.size()
	var left := randi() % _textures.size()
	var right := randi() % _textures.size()
	pending_type = SYMBOLS[center]["type"]
	pending_label = SYMBOLS[center]["label"]
	jackpot = (left == center and right == center)
	_spin_reel(0, left, 0.95, 0.35)
	_spin_reel(1, center, 1.2, 0.35)
	var last := _spin_reel(2, right, 1.5, 0.35)
	last.finished.connect(_on_spin_done)
	_update_buttons()

func _on_spin_done():
	spinning = false
	has_result = true
	if jackpot:
		result_lbl.text = "JACKPOT!  Double " + pending_label
		Audio.play_sfx("level_up")
	else:
		result_lbl.text = pending_label
	_update_buttons()

func _reroll_cost() -> int:
	return 10 * int(pow(2.0, reroll_count))

func _player_cash() -> int:
	var player = get_parent()
	if player and "cash" in player:
		return player.cash
	return 0

func _update_buttons():
	if not has_result:
		cash_lbl.text = "Chips: %d   —   pull the lever (free)" % _player_cash()
		accept_btn.hide()
	else:
		cash_lbl.text = "Chips: %d" % _player_cash()
		accept_btn.visible = not spinning
	if spinning:
		lever_hint.hide()

# Show a reroll suggestion while hovering the lever after a result.
func _on_lever_hover(hovering: bool):
	if hovering and has_result and not spinning:
		var c := _reroll_cost()
		if _player_cash() >= c:
			lever_hint.text = "REROLL (%d)" % c
			lever_hint.add_theme_color_override("font_color", Color(1, 0.9, 0.45))
		else:
			lever_hint.text = "Need %d chips" % c
			lever_hint.add_theme_color_override("font_color", Color(1, 0.5, 0.5))
		lever_hint.show()
	else:
		lever_hint.hide()

func _on_spin_pressed():
	if spinning:
		return
	if has_result:
		var c := _reroll_cost()
		if _player_cash() < c:
			return
		var player = get_parent()
		if player and player.has_method("spend_cash"):
			player.spend_cash(c)
		reroll_count += 1
	_do_spin()

func _on_accept_pressed():
	if spinning or not has_result:
		return
	var player = get_parent()
	if player and player.has_method("_apply_upgrade"):
		player._apply_upgrade(pending_type)
		if jackpot:
			player._apply_upgrade(pending_type)
	get_tree().paused = false
	queue_free()
