extends Area2D

var value: int = 1
var speed: float = 0.0
var pull_target: Node2D = null

func start_magnet(player_node):
	if pull_target == null: # Only set it once
		print("CHIP: Magnetized!")
		pull_target = player_node
		speed = 150.0 # Start with a base speed so it doesn't lag behind

func _physics_process(delta):
	if pull_target:
		# print("CHIP: Flying to player!") # Spams console, but proves it's moving
		speed += 20.0 
		global_position = global_position.move_toward(pull_target.global_position, speed * delta)

# This function name MUST match the signal connection exactly
func _on_body_entered(body):
	print("Chip touched something: ", body.name) # DEBUG PRINT
	if body.is_in_group("Player") or body.name == "Player":
		print("Success! Player collected the chip.")
		if body.has_method("collect_cash"):
			body.collect_cash(value)
		if body.has_method("collect_xp"):
			body.collect_xp(5)
		queue_free()

func _ready():
	print(name, " is actually on Layer: ", collision_layer)
	# If this prints "1" or "5", we found the problem. 
	# It should print "16" if it's truly only on the 5th checkbox.
