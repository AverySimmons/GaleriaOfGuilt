extends Node

@onready var level_generator = $LevelGenerator
@onready var map_overlay = $MapOverlay

var levels: Dictionary[Vector2, Level]

var current_level: Level
signal exited_room(dir: Vector2)

func _ready() -> void:
	levels = level_generator.get_levels(10)
	map_overlay.generate_map(levels.values())
	
	current_level = levels[Vector2.ZERO]
	add_child(current_level)
	current_level.enter(Vector2.ZERO)

func transition_levels(dir: Vector2) -> void:
	if current_level:
		remove_child(current_level)
	
	current_level = levels[current_level.map_pos + dir]
	add_child(current_level)
	current_level.enter(dir)
