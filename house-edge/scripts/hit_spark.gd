extends Node2D

# Short-lived "pop" drawn in code: an expanding ring plus a burst of dots.
# Self-frees when finished. No art assets required.

@export var duration: float = 0.35
@export var color: Color = Color(0.95, 0.3, 0.25)

var _t: float = 0.0

func _process(delta: float) -> void:
	_t += delta
	queue_redraw()
	if _t >= duration:
		queue_free()

func _draw() -> void:
	var f: float = clampf(_t / duration, 0.0, 1.0)
	var alpha: float = 1.0 - f
	var col := Color(color.r, color.g, color.b, alpha)
	var radius: float = lerpf(6.0, 40.0, f)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 24, col, 3.0, true)
	var dot_count: int = 8
	for i in dot_count:
		var ang: float = TAU * float(i) / float(dot_count)
		var pos := Vector2.RIGHT.rotated(ang) * radius
		draw_circle(pos, 1.0 + 3.0 * alpha, col)
