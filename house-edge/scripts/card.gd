extends Area2D

var speed = 400.0
var damage: int = 5
var direction = Vector2.ZERO

func _physics_process(delta):
	# Move the card towards the target every frame
	position += direction * speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Enemy"): # Damage only enemies
			body.take_damage(damage) 
			queue_free()