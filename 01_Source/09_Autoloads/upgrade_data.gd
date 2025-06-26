extends Node

const NUM_UPGRADES: int = 17
const BITE: int = 0
const SHOTGUN: int = 1
const GRENADE: int = 2
const RETRACT_SWIPE: int = 3
const DASH_DAMAGE: int = 4
const DASH_INFINITE: int = 5
const MARK_DASH: int = 6
const BB_SIZE_INC_LESS_BG: int = 7
const HIGH_BLOOD_REGEN: int = 8
const KILLS_GAIN_BLOOD_LESS_HP: int = 9
const MORE_BLOOD_EFFECT_LESS_HP: int = 10
const MORE_SPD_LESS_BG: int = 11
const SWIPE_MORE_BG: int = 12
const SWIPE_DMG_TIP: int = 13
const NORMAL_CURVE_DMG_SWIPE: int = 14
const COSTS_BLOOD_MORE_DMG: int = 15
const SPECIAL_CD_RED_COST_HP: int = 16

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
@onready var INF_DASH_CLASS = preload("res://01_Source/03_Upgrades/02_Dash_Upgrades/infinite_dash_upgrade.gd").new()
@onready var MARK_DASH_CLASS = preload("res://01_Source/03_Upgrades/02_Dash_Upgrades/mark_dash_upgrade.gd").new()
@onready var BBUP_BGDOWN_CLASS = preload("res://01_Source/03_Upgrades/03_Overall_Upgrades/bb_inc_less_blood_gain.gd").new()
@onready var HIGH_BB_REGEN_CLASS = preload("res://01_Source/03_Upgrades/03_Overall_Upgrades/high_blood_regen.gd").new()
@onready var BEUP_HPDOWN_CLASS = preload("res://01_Source/03_Upgrades/03_Overall_Upgrades/inc_blood_effect_less_hp.gd").new()
@onready var BG_KILL_HPDOWN_CLASS = preload("res://01_Source/03_Upgrades/03_Overall_Upgrades/kills_gain_blood_less_hp.gd").new()

@onready var selectable_upgrades: Array = [SHOTGUN_CLASS, GRENADE_CLASS, RETRACT_SWIPE_CLASS, DASH_DAMAGE_CLASS,
											INF_DASH_CLASS, MARK_DASH_CLASS, BBUP_BGDOWN_CLASS, HIGH_BB_REGEN_CLASS, 
											BEUP_HPDOWN_CLASS, BG_KILL_HPDOWN_CLASS]

@onready var current_ability_class = BITE_CLASS
