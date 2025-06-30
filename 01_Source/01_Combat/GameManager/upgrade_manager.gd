extends Node2D

# 1.0 would mean only unseen upgrades are chosen
var unseen_weight: float = 0.5

func _ready() -> void:
	SignalBus.levelup.connect(on_level_up)
	$UpgradeScreen.upgrade_picked.connect(pick_upgrade)
	return

func on_level_up() -> void:
	SignalBus.pause.emit()
	var chosen_upgrades = choose_upgrades()
	$UpgradeScreen.display_upgrades(chosen_upgrades)
	return

func choose_upgrades() -> Array[Upgrade]:
	if UpgradeData.selectable_upgrades.size() <= 3:
		var blank_upgrade: Upgrade = preload("res://01_Source/03_Upgrades/all_upgrades_upgrade.gd").new()
		UpgradeData.selectable_upgrades.append(blank_upgrade)
		return UpgradeData.selectable_upgrades
	
	var chosen_upgrades: Array[Upgrade]
	var unseen: bool
	var chosen_upgrade
	var upgrade_number: int
	
	while chosen_upgrades.size() < 3:
		if UpgradeData.unseen_upgrades.size() == 0:
			unseen = false
		else:
			unseen = randf() >= unseen_weight
		if unseen:
			chosen_upgrade = UpgradeData.unseen_upgrades[randi_range(0, UpgradeData.unseen_upgrades.size()-1)]
			if !chosen_upgrades.has(chosen_upgrade):
				chosen_upgrades.append(chosen_upgrade)
		else:
			chosen_upgrade = UpgradeData.selectable_upgrades[randi_range(0, UpgradeData.selectable_upgrades.size()-1)]
			if !chosen_upgrades.has(chosen_upgrade):
				chosen_upgrades.append(chosen_upgrade)
		UpgradeData.unseen_upgrades.erase(chosen_upgrade)
	return chosen_upgrades
	

func pick_upgrade(upgrade: Upgrade) -> void:
	upgrade.choose_upgrade()
	SignalBus.unpause.emit()
	return
