extends CanvasLayer

@onready var cash_label = $VBoxContainer/CashLabel
@onready var health_label = $VBoxContainer/HealthLabel
@onready var xp_label = $VBoxContainer/XPLabel
@onready var level_label = $VBoxContainer/LevelLabel

# SImple HUD in the upper left (TODO: Make it look nicer later!)

func update_cash(amount: int):
	cash_label.text = "Cash: $" + str(amount)

func update_health(current: int, maximum: int):
	health_label.text = "HP: " + str(current) + " / " + str(maximum)

func update_xp(amount: int):
	xp_label.text = "XP: " + str(amount)

func update_level(amount: int):
	level_label.text = "Level: " + str(amount)