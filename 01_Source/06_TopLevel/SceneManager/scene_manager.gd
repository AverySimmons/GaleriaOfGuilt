extends Node

var player_scene = preload("res://01_Source/00_Player/player.tscn")
var game_manager_scene = preload("res://01_Source/01_Combat/GameManager/GameManager.tscn")
var intro_scene = preload("res://01_Source/06_TopLevel/Cutscenes/intro.tscn")
var van_scene = preload("res://01_Source/06_TopLevel/Cutscenes/Road.tscn")

var title_screen
var game_manager
var intro
var van

var test_game = false

func _ready() -> void:
	Dialogic.signal_event.connect(dialogic_stupid)
	SignalBus.pause.connect(pause_game)
	SignalBus.unpause.connect(unpause_game)
	GameData.player = player_scene.instantiate()
	GameData.music_event = $GameMusic
	
	if test_game:
		$TitleScreen.call_deferred("queue_free")
		spawn_game_manager()
		return
	
	
	
	# title screen
	# intro (bar)
	# post intro (morning car)
	# time passes (morning car)
	
	# pre mall 1 (morning car)
	# mall
	# item 1
	# post mall 1 (night car)
	
	# etc mall 2 - 5
	# post mall 5 (night car)
	# ending (for now)

func spawn_game_manager():
	var t = create_tween()
	t.tween_property($CarMusic, "volume", 0, 0.5)
	$GameMusic.play()
	var t2 = create_tween()
	t2.tween_property($GameMusic, "volume", 0.35, 0.5)
	game_manager = game_manager_scene.instantiate()
	game_manager.item_dialog.connect(item_dialog)
	game_manager.stage_complete.connect(stage_complete)
	add_child(game_manager)
	
	await t.finished
	$CarMusic.stop()

func item_dialog():
	Dialogic.process_mode = Node.PROCESS_MODE_ALWAYS
	Dialogic.start("finding_item_" + str(GameData.mall_ind + 1)).process_mode = Node.PROCESS_MODE_ALWAYS

func stage_complete():
	GameData.mall_ind += 1
	game_manager.call_deferred("queue_free")
	var t = create_tween()
	t.tween_property($GameMusic, "volume", 0, 0.5)
	$CarMusic.play()
	var t2 = create_tween()
	t.tween_property($CarMusic, "volume", 0.35, 0.5)
	add_van(true)
	Dialogic.start("post_mall_" + str(GameData.mall_ind))
	
	await t.finished
	$GameMusic.stop()

func dialogic_stupid(inp: String) -> void:
	if inp == "pause_game": pause_game()
	elif inp == "unpause_game": unpause_game()
	elif inp == "next_stage": stage_complete()
	elif inp == "intro_finished": intro_finished()
	elif inp == "pre_mall_finished": pre_mall_finished()
	elif inp == "post_mall_finished": post_mall_finished()

func start_stage():
	spawn_game_manager()

func pause_game() -> void:
	get_tree().paused = true

func unpause_game() -> void:
	get_tree().paused = false

func _on_button_pressed() -> void:
	$TitleScreen.call_deferred("queue_free")
	intro = intro_scene.instantiate()
	add_child(intro)
	Dialogic.start("intro")

func intro_finished():
	intro.call_deferred("queue_free")
	var t = create_tween()
	t.tween_property($MenuMusic, "volume", 0., 0.5)
	$CarMusic.volume = 0.
	$CarMusic.play()
	var t2 = create_tween()
	t2.tween_property($CarMusic, "volume", 0.35, 0.5)
	add_van(false)
	Dialogic.start("post_intro")
	
	await t.finished
	$MenuMusic.stop()

func post_mall_finished(): # or intro finished
	add_van(false)
	Dialogic.start("pre_mall_" + str(GameData.mall_ind + 1))

func pre_mall_finished():
	remove_van()
	spawn_game_manager()

func add_van(is_night):
	if van:
		van.set_scene(is_night)
	else:
		van = van_scene.instantiate()
		van.is_night = is_night
		add_child(van)

func remove_van():
	van.call_deferred("queue_free")
