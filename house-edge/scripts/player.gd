extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


# This export variable lets you change the speed directly in the Godot Inspector!
@export var speed: float = 300.0

func _physics_process(_delta):
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction * speed
	move_and_slide()
