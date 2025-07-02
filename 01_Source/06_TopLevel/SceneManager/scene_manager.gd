extends Node

var player_scene = preload("res://01_Source/00_Player/player.tscn")
var game_manager_scene = preload("res://01_Source/01_Combat/GameManager/GameManager.tscn")
var intro_scene = preload("res://01_Source/06_TopLevel/Cutscenes/intro.tscn")
var van_scene = preload("res://01_Source/06_TopLevel/Cutscenes/Road.tscn")
var ending_scene = preload("res://01_Source/06_TopLevel/Cutscenes/ending.tscn")
var settings_scene = preload("res://01_Source/06_TopLevel/Settings/settings.tscn")
var death_scene = preload("res://01_Source/06_TopLevel/Cutscenes/death.tscn")

var title_screen
var game_manager
var intro
var van
var ending
var settings
var death

var player_dying = false

var test_game = true

var was_paused = false

func _ready() -> void:
	SignalBus.player_death.connect(player_death)
	Dialogic.signal_event.connect(dialogic_stupid)
	SignalBus.pause.connect(pause_game)
	SignalBus.unpause.connect(unpause_game)
	GameData.player = player_scene.instantiate()
	GameData.music_event = $GameMusic
	
	if test_game:
		$TitleScreen.call_deferred("queue_free")
		spawn_game_manager()
		$MenuMusic.paused = true
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

func _input(event: InputEvent) -> void:
	if player_dying: return
	if Input.is_action_just_pressed("settings"):
		if not settings:
			settings = settings_scene.instantiate()
			settings.closed.connect(settings_closed)
			$TopLevelUI.add_child(settings)
			was_paused = get_tree().paused
			get_tree().paused = true
		else:
			settings.close()

func settings_closed():
	get_tree().paused = was_paused

func spawn_game_manager():
	GameData.is_escaping = false
	player_dying = false
	var t = create_tween()
	t.tween_property($CarMusic, "volume", 0, 0.5)
	$GameMusic.play()
	var t2 = create_tween()
	t2.tween_property($GameMusic, "volume", 0.35, 0.5)
	game_manager = game_manager_scene.instantiate()
	game_manager.item_dialog.connect(item_dialog)
	game_manager.stage_complete.connect(stage_complete)
	add_child(game_manager)
	
	if GameData.mall_ind == 0 and not test_game:
		await game_manager.ready
		Dialogic.process_mode = Node.PROCESS_MODE_ALWAYS
		Dialogic.start("tutorial").process_mode = Node.PROCESS_MODE_ALWAYS
	
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
	
	if GameData.mall_ind == 5:
		ending = ending_scene.instantiate()
		add_child(ending)
		Dialogic.start("ending")
	else:
		$CarMusic.play()
		var t2 = create_tween()
		t2.tween_property($CarMusic, "volume", 0.5, 0.5)
		add_van(true)
		Dialogic.start("post_mall_" + str(GameData.mall_ind))
	
	await t.finished
	$GameMusic.stop()

func dialogic_stupid(inp: String) -> void:
	if inp == "pause_game": pause_game()
	elif inp == "unpause_game": 
		unpause_game()
		GameData.music_event.set_parameter("combat state", 2)
	elif inp == "tutorial_over": unpause_game()
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
	$ButtonClick.play()
	var t = create_tween()
	t.tween_property($MenuMusic, "volume", 0., 0.5)
	$CarMusic.volume = 0.
	$CarMusic.play()
	var t2 = create_tween()
	t2.tween_property($CarMusic, "volume", 0.5, 0.5)
	
	$TitleScreen.call_deferred("queue_free")
	intro = intro_scene.instantiate()
	add_child(intro)
	Dialogic.start("intro")
	
	await t.finished
	$MenuMusic.stop()

func intro_finished():
	intro.call_deferred("queue_free")
	add_van(false)
	Dialogic.start("post_intro")

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

func player_death():
	if player_dying: return
	player_dying = true
	GameData.music_event.set_parameter("combat state", 0)
	
	var t = create_tween()
	t.tween_property(Engine, "time_scale", 0.3, 0.5)
	
	var t2 = create_tween()
	t2.tween_property(GameData.player, "modulate", Color("red"), 0.5)
	
	await t.finished
	
	pause_game()
	
	Engine.time_scale = 1
	
	death = death_scene.instantiate()
	death.try_again.connect(death_reset)
	add_child(death)

func death_reset():
	GameData.player.reset()
	GameData.player.get_parent().remove_child(GameData.player)
	game_manager.call_deferred("queue_free")
	spawn_game_manager()


func _on_button_mouse_entered() -> void:
	$ButtonHover.play()
