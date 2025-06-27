extends Node

var player_scene = preload("res://01_Source/00_Player/player.tscn")
var game_manager_scene = preload("res://01_Source/01_Combat/GameManager/GameManager.tscn")

var title_screen
var game_manager

func _ready() -> void:
	GameData.player = player_scene.instantiate()
	GameData.music_event = $FmodEventEmitter2D
	spawn_game_manager()

func spawn_game_manager():
	game_manager = game_manager_scene.instantiate()
	game_manager.item_dialog.connect(item_dialog)
	game_manager.stage_complete.connect(stage_complete)
	add_child(game_manager)

func item_dialog():
	Dialogic.start("finding_item_" + str(GameData.mall_ind + 1))

func stage_complete():
	GameData.mall_ind += 1
	game_manager.call_deferred("queue_free")
	Dialogic.start("post_mall_" + str(GameData.mall_ind))

func dialogic_stupid(inp: String) -> void:
	if inp == "pause_game": pause_game()
	elif inp == "unpause_game": unpause_game()
	elif inp == "next_stage": stage_complete()

func start_stage():
	spawn_game_manager()

func pause_game() -> void:
	get_tree().paused = true

func unpause_game() -> void:
	get_tree().paused = false
