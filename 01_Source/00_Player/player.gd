extends CharacterBody2D


@export var top_speed: float = 50



func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var movement_vector: Vector2 = Input.get_vector("left", "right", "up", "down")
	pass
