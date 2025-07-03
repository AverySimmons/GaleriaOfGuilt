extends Node

@onready var level_generator = $LevelGenerator
@onready var map_overlay = $CanvasLayer/MapOverlay

var levels: Dictionary[Vector2, Level]
var current_level: Level

var mall_sizes = [
	4,
	6,
	8,
	10,
	12
]

signal item_dialog()
signal stage_complete()
signal level_exit()
signal level_enter()

func _ready() -> void:
	GameData.player.reset()
	levels = level_generator.get_levels(mall_sizes[GameData.mall_ind])
	map_overlay.generate_map(levels.values())
	
	for lvl: Level in levels.values():
		lvl.exited_room.connect(transition_levels)
		lvl.item_picked_up.connect(item_picked_up)
	
	current_level = levels[Vector2.ZERO]
	add_child(current_level)
	current_level.enter(Vector2.ZERO)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("map"):
		$CanvasLayer/MapOverlay/AnimationPlayer.play("on")
	if Input.is_action_just_released("map"):
		$CanvasLayer/MapOverlay/AnimationPlayer.play("off")
	if Input.is_action_just_pressed("levelup_debug"):
		SignalBus.levelup.emit()

func transition_levels(dir: Vector2) -> void:
	if current_level:
		level_exit.emit()
		await get_tree().create_timer(0.2).timeout
		current_level.blood_manager.despawn()
		remove_child(current_level)
	
	if dir == Vector2.ZERO:
		stage_complete.emit()
		return
	
	current_level = levels[current_level.map_pos + dir]
	add_child(current_level)
	current_level.enter(dir)
	
	map_overlay.map_position = current_level.map_pos
	map_overlay.display()
	if !is_inside_tree(): return
	await get_tree().create_timer(0.1, false).timeout
	level_enter.emit()

func item_picked_up():
	GameData.is_escaping = true
	item_dialog.emit()
