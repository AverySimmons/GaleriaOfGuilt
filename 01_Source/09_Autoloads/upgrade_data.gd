extends Node

const NUM_UPGRADES: int = 4
const BITE: int = 0
const SHOTGUN: int = 1
const GRENADE: int = 2
const RETRACT_SWIPE: int = 3

var upgrades_gained: Array

func _ready() -> void:
	for i in range(NUM_UPGRADES):
		upgrades_gained.append(false)
	pass

const BITE_CLASS = preload("res://01_Source/03_Upgrades/01_Special_Upgrades/bite_upgrade.gd")
const SHOTGUN_CLASS = preload("res://01_Source/03_Upgrades/01_Special_Upgrades/shotgun_upgrade.gd")
const GRENADE_CLASS = preload("res://01_Source/03_Upgrades/01_Special_Upgrades/grenade_upgrade.gd")
const CHARGE_SWIPE_CLASS = preload("res://01_Source/03_Upgrades/00_Swipe_Upgrades/third_slash_more_dmg.gd")

var selectable_upgrades: Array = [BITE_CLASS.new()]
