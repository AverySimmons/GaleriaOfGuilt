extends Control

@onready var choice_1: Control = $Choice1
@onready var choice_2: Control = $Choice2
@onready var choice_3: Control = $Choice3
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var choices = []

signal upgrade_picked(upgrade: Upgrade)

func _ready() -> void:
	choices = [choice_1, choice_2, choice_3]
	
	for c in choices:
		c.pause_choices.connect(choice_clicked)
		c.chosen.connect(choice_chosen)

func display_upgrades(upgrades: Array[Upgrade]) -> void:
	for i in 3:
		choices[i].format(upgrades[i])
	
	animation_player.play("fly_in")
	await animation_player.animation_finished
	for c in choices:
		c.turn_on_signals()

func choice_clicked():
	for c in choices:
		c.turn_off_signals()

func choice_chosen(upgrade: Upgrade):
	animation_player.play("fly_out")
	await animation_player.animation_finished
	upgrade_picked.emit(upgrade)
