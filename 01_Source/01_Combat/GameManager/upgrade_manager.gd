extends Node2D

func _ready() -> void:
	SignalBus.levelup.connect(on_level_up)
	return

func on_level_up() -> void:
	return
