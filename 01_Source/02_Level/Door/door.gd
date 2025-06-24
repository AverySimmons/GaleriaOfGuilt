class_name Door
extends Area2D

@export var direction: Vector2 = Vector2.ZERO
@onready var player_spawn: Marker2D = $PlayerSpawn

signal exit(dir: Vector2)

func _ready() -> void:
	area_entered.connect(attempt_exit)

func attempt_exit(a: Area2D):
	exit.emit(direction)
