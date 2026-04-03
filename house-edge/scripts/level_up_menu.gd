extends CanvasLayer

# Upgrade menu picker (very basic for now, but we will make it look nicer later)

signal choice_made(type)

func _ready():
	# Connect all buttons
	$CenterContainer/PanelContainer/VBoxContainer/DamageBtn.pressed.connect(func(): _on_click("damage"))
	$CenterContainer/PanelContainer/VBoxContainer/SpeedBtn.pressed.connect(func(): _on_click("speed"))
	$CenterContainer/PanelContainer/VBoxContainer/ShootBtn.pressed.connect(func(): _on_click("shoot"))
	$CenterContainer/PanelContainer/VBoxContainer/MagnetBtn.pressed.connect(func(): _on_click("magnet"))
	$CenterContainer/PanelContainer/VBoxContainer/RegenBtn.pressed.connect(func(): _on_click("regen"))

func _on_click(type):
	choice_made.emit(type)
	get_tree().paused = false # Unpause the game
	queue_free() # Close menu
