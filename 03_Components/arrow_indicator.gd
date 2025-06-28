class_name ArrowIndicator
extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

@export var color: Color = Color(1,1,1,1)
@export var arrow_size: float = 32.

func update(start: Vector2, end: Vector2) -> void:
	sprite.global_position = (start + end) * 0.5
	rotation = start.angle_to_point(end)
	sprite.material.set_shader_parameter("arrow_size", arrow_size)
	sprite.material.set_shader_parameter("size", start.distance_to(end))
	sprite.modulate = color
	sprite.scale.x = start.distance_to(end) / 64.

func conceal() -> void:
	var t = create_tween()
	var new_col = color
	new_col.a = 0
	t.tween_property(sprite, "modulate", new_col, 0.25)
	await t.finished
	call_deferred("queue_free")
