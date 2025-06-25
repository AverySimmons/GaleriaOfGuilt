extends Node

const NUM_UPGRADES: int = 2
const SWIPE_BB_INCREASE: int = 0
const jfdbkjdj: int = 1

var upgrades_gained: Array

func _ready() -> void:
	for i in range(NUM_UPGRADES):
		upgrades_gained.append(false)
	pass
