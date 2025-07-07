extends Node2D

@onready var entities: Node2D = $Entities


func _ready() -> void:
	GameData.player.global_position = $PlayerSpawn.global_position
	entities.add_child(GameData.player)
