extends CanvasLayer

@onready var xp_bar = $XPBar
@onready var cash_label = $CoinBox/CashLabel

func update_cash(amount: int):
	cash_label.text = str(amount)

# Kept for compatibility; HP is now shown on the world-space bar above the player.
func update_health(_current: int, _maximum: int):
	pass

func update_xp(current: int, maximum: int):
	xp_bar.max_value = maximum
	xp_bar.value = current

# Level is no longer shown in the HUD; kept for compatibility with callers.
func update_level(_amount: int):
	pass
