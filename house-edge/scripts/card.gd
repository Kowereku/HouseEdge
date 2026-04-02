extends Area2D

var speed = 400.0
var direction = Vector2.ZERO

func _physics_process(delta):
	# Move the card forward every frame
	position += direction * speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free() # Deletes the card from memory

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	pass # Replace with function body.
