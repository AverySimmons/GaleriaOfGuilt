extends Node2D

var player_scene = preload("res://01_Source/00_Player/player.tscn")

func _ready():
	var player = player_scene.instantiate()
	player.position = Vector2(0, 0)
	add_child(player)
	return
