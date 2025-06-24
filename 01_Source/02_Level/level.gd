class_name Level
extends Node2D

@onready var entities: Node2D = $Entities
@onready var doors: Node2D = $Doors

# 0 is no connection
# 1 is up
# 2 is down
var connections: Array[int] = [0, 0, 0, 0]
var is_end: bool = false
var map_pos: Vector2 = Vector2.ZERO
var map_piece: MapPiece = null

signal exited_room(dir: Vector2)

func _ready() -> void:
	for d: Door in doors.get_children():
		if connections[GameData.DIRECTIONS[d.direction]]:
			d.exit.connect(exit, ConnectFlags.CONNECT_DEFERRED)
		else:
			d.queue_free()

func enter(dir: Vector2) -> void:
	if map_pos == Vector2.ZERO:
		GameData.player.global_position = Vector2(1280,720) * 0.5
		entities.add_child(GameData.player)
		return
	
	for d: Door in doors.get_children():
		if d.direction == dir * -1:
			GameData.player.global_position = d.player_spawn.global_position
			entities.add_child(GameData.player)
			break

func exit(dir: Vector2):
	entities.remove_child(GameData.player)
	exited_room.emit(dir)

func _physics_process(delta: float) -> void:
	pass
