extends Node

const NUM_UPGRADES: int = 5
const BITE: int = 0
const SHOTGUN: int = 1
const GRENADE: int = 2
const RETRACT_SWIPE: int = 3
const DASH_DAMAGE: int = 4

var upgrades_gained: Array

func _ready() -> void:
	for i in range(NUM_UPGRADES):
		upgrades_gained.append(false)
	pass

@onready var BITE_CLASS = preload("res://01_Source/03_Upgrades/01_Special_Upgrades/bite_upgrade.gd").new()
@onready var SHOTGUN_CLASS = preload("res://01_Source/03_Upgrades/01_Special_Upgrades/shotgun_upgrade.gd").new()
@onready var GRENADE_CLASS = preload("res://01_Source/03_Upgrades/01_Special_Upgrades/grenade_upgrade.gd").new()
@onready var RETRACT_SWIPE_CLASS = preload("res://01_Source/03_Upgrades/00_Swipe_Upgrades/third_slash_more_dmg.gd").new()
@onready var DASH_DAMAGE_CLASS = preload("res://01_Source/03_Upgrades/02_Dash_Upgrades/dash_damage.gd").new()

@onready var selectable_upgrades: Array = [SHOTGUN_CLASS, GRENADE_CLASS, RETRACT_SWIPE_CLASS, DASH_DAMAGE_CLASS,
								  ]
