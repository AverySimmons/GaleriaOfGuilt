class_name Level
extends Node2D

var connections: Array[Level] = [null, null, null, null]
var is_start: bool = false
var is_end: bool = false
var map_pos: Vector2 = Vector2.ZERO

var player
