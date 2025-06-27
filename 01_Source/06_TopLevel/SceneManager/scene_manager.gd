extends Node

var player_scene = preload("res://01_Source/00_Player/player.tscn")
var game_manager_scene = preload("res://01_Source/01_Combat/GameManager/GameManager.tscn")

var title_screen
var game_manager

func _ready() -> void:
	GameData.player = player_scene.instantiate()
	
	GameData.music_event = $FmodEventEmitter2D
	
	game_manager = game_manager_scene.instantiate()
	add_child(game_manager)



func pause_game() -> void:
	get_tree().paused = true

func unpause_game() -> void:
	get_tree().paused = false
