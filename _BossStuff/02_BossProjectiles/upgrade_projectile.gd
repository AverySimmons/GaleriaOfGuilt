extends Area2D

@onready var blood_sprite: Sprite2D = $Sprite2D
var y_offset: float
var target_position: Vector2

func _ready() -> void:
	return

func _process(delta: float) -> void:
	blood_sprite.global_position.y = global_position.y + y_offset
	$ScalingShadow.material.set_shader_parameter("z", -y_offset)
	return

func get_shot(input_y_offset: float, input_target_position: Vector2) -> void:
	y_offset = input_y_offset
	target_position = input_target_position
	rotation = (global_position + Vector2(0, input_y_offset)).angle_to(input_target_position) + 1.5*PI
	var t: Tween = create_tween()
	t.tween_property(self, "global_position", target_position, 0.5)
	var t2: Tween = create_tween()
	t2.tween_property(self, "y_offset", 0, 0.5)
	
	await t2.finished
	queue_free()
	return
