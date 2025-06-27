extends Node2D

# 1.0 would mean only unseen upgrades are chosen
var unseen_weight: float = 0.5

func _ready() -> void:
	SignalBus.levelup.connect(on_level_up)
	return

func on_level_up() -> void:
	SignalBus.pause.emit
	return

func choose_upgrades() -> Array:
	if UpgradeData.selectable_upgrades.size() <= 3:
		return UpgradeData.selectable_upgrades
	
	var chosen_upgrades: Array
	var unseen: bool
	var chosen_upgrade
	var upgrade_number: int
	
	while chosen_upgrades.size() < 3:
		unseen = randf() >= unseen_weight
		if unseen:
			pass
	
	return chosen_upgrades
	
