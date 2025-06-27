extends Sprite2D

signal found()

func _ready() -> void:
	$Area2D.area_entered.connect(picked_up, ConnectFlags.CONNECT_DEFERRED)

func picked_up(_area):
	found.emit()
	queue_free()
