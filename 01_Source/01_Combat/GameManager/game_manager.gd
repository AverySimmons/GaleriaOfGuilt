extends Node

@onready var level_generator = $LevelGenerator
@onready var map_overlay = $MapOverlay

var levels: Dictionary[Vector2, Level]

var current_level: Level

func _ready() -> void:
	levels = level_generator.get_levels(10)
	map_overlay.generate_map(levels.values())

func transition_levels(dir: Vector2) -> void:
	pass
