extends CanvasLayer

@onready var coins_label = $Panel/VBoxContainer/Header/CoinsLabel
@onready var hp_level_label = $Panel/VBoxContainer/HPRow/LevelLabel
@onready var hp_cost_label = $Panel/VBoxContainer/HPRow/CostLabel
@onready var hp_buy_btn = $Panel/VBoxContainer/HPRow/BuyButton

@onready var regen_level_label = $Panel/VBoxContainer/RegenRow/LevelLabel
@onready var regen_cost_label = $Panel/VBoxContainer/RegenRow/CostLabel
@onready var regen_buy_btn = $Panel/VBoxContainer/RegenRow/BuyButton

@onready var speed_level_label = $Panel/VBoxContainer/SpeedRow/LevelLabel
@onready var speed_cost_label = $Panel/VBoxContainer/SpeedRow/CostLabel
@onready var speed_buy_btn = $Panel/VBoxContainer/SpeedRow/BuyButton

@onready var aspd_level_label = $Panel/VBoxContainer/AspdRow/LevelLabel
@onready var aspd_cost_label = $Panel/VBoxContainer/AspdRow/CostLabel
@onready var aspd_buy_btn = $Panel/VBoxContainer/AspdRow/BuyButton

func _ready():
	_update_ui()

func _update_ui():
	coins_label.text = str(MetaProgression.gold_coins)
	
	_update_row(hp_level_label, hp_cost_label, hp_buy_btn, "Max HP", MetaProgression.upgrade_max_hp)
	_update_row(regen_level_label, regen_cost_label, regen_buy_btn, "HP Regen", MetaProgression.upgrade_hp_regen)
	_update_row(speed_level_label, speed_cost_label, speed_buy_btn, "Movement Speed", MetaProgression.upgrade_move_speed)
	_update_row(aspd_level_label, aspd_cost_label, aspd_buy_btn, "Attack Speed", MetaProgression.upgrade_attack_speed)

func _update_row(lvl_label: Label, cost_label: Label, btn: Button, stat_name: String, current_tier: int):
	lvl_label.text = stat_name + " (Lv " + str(current_tier) + "/" + str(MetaProgression.MAX_TIER) + ")"
	
	if current_tier >= MetaProgression.MAX_TIER:
		cost_label.text = "MAXED"
		btn.disabled = true
	else:
		var cost = MetaProgression.get_upgrade_cost(current_tier)
		cost_label.text = "Cost: " + str(cost)
		btn.disabled = MetaProgression.gold_coins < cost

func _buy_upgrade(stat: String):
	var current_tier = MetaProgression.get("upgrade_" + stat)
	if current_tier >= MetaProgression.MAX_TIER:
		return
	
	var cost = MetaProgression.get_upgrade_cost(current_tier)
	if MetaProgression.gold_coins >= cost:
		MetaProgression.gold_coins -= cost
		MetaProgression.set("upgrade_" + stat, current_tier + 1)
		MetaProgression.save_data()
		_update_ui()

func _on_hp_buy_pressed():
	_buy_upgrade("max_hp")

func _on_regen_buy_pressed():
	_buy_upgrade("hp_regen")

func _on_speed_buy_pressed():
	_buy_upgrade("move_speed")

func _on_aspd_buy_pressed():
	_buy_upgrade("attack_speed")

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
