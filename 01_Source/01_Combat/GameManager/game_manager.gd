extends Node

@onready var level_generator = $LevelGenerator
@onready var map_overlay = $CanvasLayer/MapOverlay

var player_scene = preload("res://01_Source/00_Player/player.tscn")

var levels: Dictionary[Vector2, Level]
var current_level: Level

var size: float = 10

func _ready() -> void:
	GameData.music_event = $FmodEventEmitter2D
	levels = level_generator.get_levels(size)
	map_overlay.generate_map(levels.values())
	
	for lvl: Level in levels.values():
		lvl.exited_room.connect(transition_levels)
	
	GameData.player = player_scene.instantiate()
	
	current_level = levels[Vector2.ZERO]
	add_child(current_level)
	current_level.enter(Vector2.ZERO)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("map"):
		$CanvasLayer/MapOverlay/AnimationPlayer.play("on")
	if Input.is_action_just_released("map"):
		$CanvasLayer/MapOverlay/AnimationPlayer.play("off")

func transition_levels(dir: Vector2) -> void:
	if current_level:
		current_level.blood_manager.despawn()
		remove_child(current_level)
	
	current_level = levels[current_level.map_pos + dir]
	add_child(current_level)
	current_level.enter(dir)
	
	map_overlay.map_position = current_level.map_pos
	map_overlay.display()
