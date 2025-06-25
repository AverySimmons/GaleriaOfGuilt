class_name Upgrade
extends Node

var upgrade_name: String
var upgrade_description: String
var upgrade_number: int
var icon

func choose_upgrade() -> void:
	UpgradeData.upgrades_gained[upgrade_number] = true
	return
