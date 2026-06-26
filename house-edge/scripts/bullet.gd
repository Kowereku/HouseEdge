extends Area2D

# Straight, fast, low-damage bullet for the gun weapon. Hits one enemy.

@export var speed: float = 720.0
var damage: int = 3
var direction := Vector2.ZERO

func _physics_process(delta):
	position += direction * speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Enemy"):
		body.take_damage(damage, global_position)
		Audio.play_sfx("hit")
		queue_free()
