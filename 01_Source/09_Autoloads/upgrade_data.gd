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

const BITE_SCENE = 1
const SHOTGUN_SCENE = 2
const GRENADE_SCENE = 3
