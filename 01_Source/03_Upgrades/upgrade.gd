class_name Upgrade
extends Node

var upgrade_name: String
var upgrade_description: String
var upgrade_number: int
var upgrade_scene
var icon
@onready var player = GameData.player

func choose_upgrade() -> void:
	UpgradeData.upgrades_gained[upgrade_number] = true
	UpgradeData.selectable_upgrades.erase(upgrade_scene)
	return
