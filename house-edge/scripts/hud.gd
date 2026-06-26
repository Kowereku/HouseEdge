extends CanvasLayer

# XP bar: ornate frame (xp_frame.png) with a purple crystal fill (xp_fill.png)
# clipped to the XP ratio. Coins shown top-right.

const XP_FRAME_W := 392.0
const XP_FRAME_NATIVE := Vector2(2608.0, 408.0)
# Inner window of the frame as fractions of the frame size (where the fill sits).
const WIN_FRAC := Rect2(0.1449, 0.1446, 0.8006, 0.4142)

@onready var cash_label = $CoinBox/CashLabel
@onready var gold_label = $GoldBox/GoldLabel

var _xp_fill_clip: Control
var _xp_win_w: float = 0.0

func _ready():
	_build_xp_bar()

func _process(delta):
	if is_instance_valid(gold_label) and RunConfig:
		gold_label.text = str(RunConfig.gold_collected)

func _build_xp_bar():
	var fw := XP_FRAME_W
	var fh := fw * XP_FRAME_NATIVE.y / XP_FRAME_NATIVE.x
	var fx := 0.0
	var fy := 0.0

	var frame := TextureRect.new()
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_SCALE
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists("res://assets/xp_frame.png"):
		frame.texture = load("res://assets/xp_frame.png")
	frame.position = Vector2(fx, fy)
	frame.size = Vector2(fw, fh)
	add_child(frame)

	# Inner window in screen coords.
	var wx := fx + WIN_FRAC.position.x * fw
	var wy := fy + WIN_FRAC.position.y * fh
	_xp_win_w = WIN_FRAC.size.x * fw
	var wh := WIN_FRAC.size.y * fh

	# Clip reveals the left part of the fill according to XP ratio.
	_xp_fill_clip = Control.new()
	_xp_fill_clip.clip_contents = true
	_xp_fill_clip.position = Vector2(wx, wy)
	_xp_fill_clip.size = Vector2(0, wh)
	_xp_fill_clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_xp_fill_clip)

	var fill := TextureRect.new()
	fill.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fill.stretch_mode = TextureRect.STRETCH_SCALE
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists("res://assets/xp_fill.png"):
		fill.texture = load("res://assets/xp_fill.png")
	fill.position = Vector2.ZERO
	fill.size = Vector2(_xp_win_w, wh)
	_xp_fill_clip.add_child(fill)

func update_cash(amount: int):
	cash_label.text = str(amount)

# Health is shown on the world-space bar above the player.
func update_health(_current: int, _maximum: int):
	pass

func update_xp(current: int, maximum: int):
	if not is_instance_valid(_xp_fill_clip):
		return
	var ratio := clampf(float(current) / maxf(1.0, float(maximum)), 0.0, 1.0)
	var tw := create_tween()
	tw.tween_property(_xp_fill_clip, "size:x", _xp_win_w * ratio, 0.18)

# Level no longer shown in the HUD; kept for compatibility with callers.
func update_level(_amount: int):
	pass
