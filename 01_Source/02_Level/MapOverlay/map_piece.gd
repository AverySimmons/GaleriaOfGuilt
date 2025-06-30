class_name MapPiece
extends Sprite2D

var connections = [false, false, false, false]

func _ready() -> void:
	visible = false
	for i in 4:
		get_children()[i].visible = connections[i]
