extends Node

const NUM_UPGRADES: int = 3
const BITE: int = 0
const SHOTGUN: int = 1
const GRENADE: int = 2

var upgrades_gained: Array

func _ready() -> void:
	for i in range(NUM_UPGRADES):
		upgrades_gained.append(false)
	pass

const BITE_SCENE = preload("res://01_Source/03_Upgrades/01_Special_Upgrades/bite_upgrade.gd")
const SHOTGUN_SCENE = preload("res://01_Source/03_Upgrades/01_Special_Upgrades/shotgun_upgrade.gd")
const GRENADE_SCENE = preload("res://01_Source/03_Upgrades/01_Special_Upgrades/grenade_upgrade.gd")

var selectable_upgrades: Array = []
