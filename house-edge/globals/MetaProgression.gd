extends Node

const SAVE_PATH := "user://meta_progression.cfg"

var gold_coins: int = 0

var upgrade_max_hp: int = 0
var upgrade_hp_regen: int = 0
var upgrade_move_speed: int = 0
var upgrade_attack_speed: int = 0

const MAX_TIER: int = 5
const COSTS := [10, 25, 50, 100, 200]

func _ready():
	load_data()

func load_data():
	var cfg := ConfigFile.new()
	var err := cfg.load(SAVE_PATH)
	if err != OK:
		return
	
	gold_coins = cfg.get_value("meta", "gold_coins", 0)
	upgrade_max_hp = cfg.get_value("meta", "upgrade_max_hp", 0)
	upgrade_hp_regen = cfg.get_value("meta", "upgrade_hp_regen", 0)
	upgrade_move_speed = cfg.get_value("meta", "upgrade_move_speed", 0)
	upgrade_attack_speed = cfg.get_value("meta", "upgrade_attack_speed", 0)

func save_data():
	var cfg := ConfigFile.new()
	cfg.set_value("meta", "gold_coins", gold_coins)
	cfg.set_value("meta", "upgrade_max_hp", upgrade_max_hp)
	cfg.set_value("meta", "upgrade_hp_regen", upgrade_hp_regen)
	cfg.set_value("meta", "upgrade_move_speed", upgrade_move_speed)
	cfg.set_value("meta", "upgrade_attack_speed", upgrade_attack_speed)
	cfg.save(SAVE_PATH)

func add_coins(amount: int):
	gold_coins += amount
	save_data()

func get_upgrade_cost(tier: int) -> int:
	if tier >= MAX_TIER:
		return 999999
	return COSTS[tier]

# -----------------
# Getters for Stats
# -----------------

func get_bonus_hp() -> int:
	# e.g., +5 HP per tier
	return upgrade_max_hp * 5

func get_bonus_regen() -> float:
	# e.g., 0.5 HP regen per second per tier
	return upgrade_hp_regen * 0.5

func get_bonus_speed() -> float:
	# e.g., +10.0 speed per tier
	return upgrade_move_speed * 10.0

func get_bonus_attack_speed() -> float:
	# e.g., 5% faster attack speed per tier (multiplicative or additive)
	# Returns a multiplier. 0 tier = 1.0. 5 tier = 1.25.
	return 1.0 + (upgrade_attack_speed * 0.05)
