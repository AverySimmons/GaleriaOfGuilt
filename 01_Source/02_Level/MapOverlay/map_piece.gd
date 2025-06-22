extends Sprite2D

var connections = [false, false, false, false]

func _ready() -> void:
	for i in 4:
		get_children()[i].visible = connections[i]
