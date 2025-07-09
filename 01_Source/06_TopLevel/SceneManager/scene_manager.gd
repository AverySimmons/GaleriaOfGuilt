extends Node

@onready var transition_player: AnimationPlayer = $TransitionPlayer
@onready var fade_rect: ColorRect = $TopLevelUI/FadeRect
@onready var circ_fade_rect: ColorRect = $TopLevelUI/CircFadeRect
@onready var level_swap: ColorRect = $TopLevelUI/LevelSwap


var player_scene = preload("res://01_Source/00_Player/player.tscn")
var game_manager_scene = preload("res://01_Source/01_Combat/GameManager/GameManager.tscn")
var intro_scene = preload("res://01_Source/06_TopLevel/Cutscenes/intro.tscn")
var van_scene = preload("res://01_Source/06_TopLevel/Cutscenes/Road.tscn")
var ending_scene = preload("res://01_Source/06_TopLevel/Cutscenes/ending.tscn")
var settings_scene = preload("res://01_Source/06_TopLevel/Settings/settings.tscn")
var death_scene = preload("res://01_Source/06_TopLevel/Cutscenes/death.tscn")
var boss_scene = preload("res://_BossStuff/BossLevel/boss_level.tscn")

var title_screen
var game_manager
var intro
var van
var ending
var settings
var death
var boss_level

var player_dying = false

var test_game = true
var test_boss = true

var tut2 = false
var boss_intro_played = true

func _ready() -> void:
	if test_boss:
		GameData.mall_ind = 5
	
	SignalBus.player_death.connect(player_death)
	Dialogic.signal_event.connect(dialogic_stupid)
	SignalBus.pause.connect(pause_game)
	SignalBus.unpause.connect(unpause_game)
	GameData.player = player_scene.instantiate()
	GameData.music_event = $GameMusic
	
	var t = create_tween()
	t.tween_property($MenuMusic, "volume", 1.5, 0.5)
	
	if test_game:
		$TitleScreen.call_deferred("queue_free")
		if test_boss:
			spawn_boss_level()
		else:
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
			$TopLevelUI.add_child(settings)
			get_tree().paused = true
		else:
			settings.close()

func spawn_boss_level():
	player_dying = false
	boss_level = boss_scene.instantiate()
	boss_level.boss_defeated.connect(boss_defeated)
	boss_level.try_again_mode = boss_intro_played
	boss_intro_played = true
	add_child(boss_level)

func spawn_game_manager():
	GameData.is_escaping = false
	player_dying = false
	game_manager = game_manager_scene.instantiate()
	game_manager.item_dialog.connect(item_dialog)
	game_manager.stage_complete.connect(stage_complete)
	game_manager.level_exit.connect(exit_level_transition)
	game_manager.level_enter.connect(enter_level_transition)
	add_child(game_manager)

func exit_level_transition():
	level_swap.material.set_shader_parameter("rot", randf_range(0,TAU))
	pause_game()
	transition_player.play("line_wipe_out")
	await transition_player.animation_finished
	unpause_game()

func enter_level_transition():
	pause_game()
	transition_player.play("line_wipe_in")
	await transition_player.animation_finished
	unpause_game()
	if not tut2:
		tut2 = true
		Dialogic.process_mode = Node.PROCESS_MODE_ALWAYS
		Dialogic.start("tutorial2").process_mode = Node.PROCESS_MODE_ALWAYS

func item_dialog():
	Dialogic.process_mode = Node.PROCESS_MODE_ALWAYS
	Dialogic.start("finding_item_" + str(GameData.mall_ind + 1)).process_mode = Node.PROCESS_MODE_ALWAYS

func stage_complete():
	if player_dying: return
	GameData.mall_ind += 1
	game_manager.call_deferred("queue_free")
	var t = create_tween()
	t.tween_property($GameMusic, "volume", 0, 0.5)
	
	await get_tree().create_timer(1.5).timeout
	$CarMusic.play()
	var t2 = create_tween()
	t2.tween_property($CarMusic, "volume", 0.5, 1)
	add_van(true)
	transition_player.play("line_wipe_in")
	await transition_player.animation_finished
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

func pause_game() -> void:
	get_tree().paused = true

func unpause_game() -> void:
	get_tree().paused = false

func _on_button_pressed() -> void:
	$ButtonClick.play()
	var t = create_tween()
	t.tween_property($MenuMusic, "volume", 0., 0.5)
	
	transition_player.play("fade_out")
	await transition_player.animation_finished
	
	$TitleScreen.call_deferred("queue_free")
	intro = intro_scene.instantiate()
	add_child(intro)
	
	await get_tree().create_timer(0.5).timeout
	
	$CarMusic.volume = 0.
	$CarMusic.play()
	var t2 = create_tween()
	t2.tween_property($CarMusic, "volume", 0.5, 0.5)
	
	transition_player.play("fade_in")
	await transition_player.animation_finished
	
	Dialogic.start("intro")
	
	$MenuMusic.stop()

func intro_finished():
	fade_rect.self_modulate = Color("06000d")
	
	var t = create_tween()
	t.tween_property($CarMusic, "volume", 0., 0.5)
	transition_player.play("fade_out")
	await transition_player.animation_finished
	intro.call_deferred("queue_free")
	$CarStart.play()
	await get_tree().create_timer(3).timeout
	add_van(false)
	transition_player.play("fade_in")
	await transition_player.animation_finished
	var t2 = create_tween()
	t2.tween_property($CarMusic, "volume", 0.5, 1)
	await t2.finished
	Dialogic.start("post_intro")

func post_mall_finished(): # or post intro finished
	var t = create_tween()
	t.tween_property($CarMusic, "volume", 0., 0.5)
	transition_player.play("circ_fade_out")
	await transition_player.animation_finished
	
	# play sound
	await get_tree().create_timer(1).timeout
	$Sigh.play()
	add_van(false)
	if !is_inside_tree(): return
	await get_tree().create_timer(3).timeout
	
	transition_player.play("circ_fade_in")
	await transition_player.animation_finished
	
	var t2 = create_tween()
	t2.tween_property($CarMusic, "volume", 0.5, 1)
	await t2.finished
	Dialogic.start("pre_mall_" + str(GameData.mall_ind + 1))

func pre_mall_finished():
	var t = create_tween()
	t.tween_property($CarMusic, "volume", 0, 0.5)
	
	level_swap.material.set_shader_parameter("offset", randf())
	level_swap.material.set_shader_parameter("rot", randf_range(0,TAU))
	
	transition_player.play("line_wipe_out")
	await transition_player.animation_finished
	
	$CarMusic.stop()
	remove_van()
	
	if GameData.mall_ind == 5:
		spawn_boss_level()
	else:
		spawn_game_manager()
	
	await get_tree().create_timer(0.1).timeout
	pause_game()
	
	if !is_inside_tree(): return
	await get_tree().create_timer(1).timeout
	
	transition_player.play("line_wipe_in")
	await transition_player.animation_finished
	
	if GameData.mall_ind == 5:
		$BossMusic.play()
		var t2 = create_tween()
		t2.tween_property($BossMusic, "volume", 0.35, 1)
	else:
		$GameMusic.play()
		var t2 = create_tween()
		t2.tween_property($GameMusic, "volume", 0.35, 1)
	
	if !is_inside_tree(): return
	await get_tree().create_timer(1).timeout
	unpause_game()
	
	if GameData.mall_ind == 0 and not test_game:
		Dialogic.process_mode = Node.PROCESS_MODE_ALWAYS
		Dialogic.start("tutorial").process_mode = Node.PROCESS_MODE_ALWAYS
	if GameData.mall_ind == 5:
		Dialogic.process_mode = Node.PROCESS_MODE_ALWAYS
		Dialogic.start("pre_boss").process_mode = Node.PROCESS_MODE_ALWAYS

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
	
	pause_game()
	
	var t2 = create_tween()
	t2.tween_property(GameData.player, "modulate", Color("red"), 0.5)
	
	
	await t2.finished
	
	death = death_scene.instantiate()
	death.try_again.connect(death_reset)
	add_child(death)

func death_reset():
	GameData.player.reset()
	GameData.player.get_parent().remove_child(GameData.player)
	if game_manager:
		game_manager.call_deferred("queue_free")
	if boss_level:
		boss_level.call_deferred("queue_free")
	
	if GameData.mall_ind == 5:
		spawn_boss_level()
	else:
		spawn_game_manager()

func _on_button_mouse_entered() -> void:
	$ButtonHover.play()
	$TitleScreen/Button/ColorRect.color.a = 0.15

func _on_button_mouse_exited() -> void:
	$TitleScreen/Button/ColorRect.color.a = 0.

func boss_defeated() -> void:
	fade_rect.self_modulate = Color("06000d")
	pause_game()
	var t = create_tween()
	t.tween_property($BossMusic, "volume", 0., 0.5)
	
	transition_player.play("fade_out")
	await transition_player.animation_finished
	$BossMusic.stop()
	
	boss_level.queue_free()
	unpause_game()
	
	await get_tree().create_timer(2, false).timeout
	
	$EndingMusic.play()
	var t2 = create_tween()
	t2.tween_property($EndingMusic, "volume", 0.5, 1)
	
	ending = ending_scene.instantiate()
	add_child(ending)
	transition_player.play("fade_in")
	await transition_player.animation_finished
	Dialogic.start("ending")
