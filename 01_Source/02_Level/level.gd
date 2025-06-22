class_name Level
extends Node2D

var connections: Array[bool] = [false, false, false, false]
var is_end: bool = false
var map_pos: Vector2 = Vector2.ZERO
var map_piece: MapPiece = null

var player: Player
