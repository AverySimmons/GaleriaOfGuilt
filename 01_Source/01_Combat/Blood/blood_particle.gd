class_name BloodParticle
extends Area2D

const DEACC = 2500

var sprite_frame = 0

signal stopped(pos: Vector2, rot: float, frame: int)

var velocity = Vector2.ZERO
var disapearing = false

func _ready() -> void:
	sprite_frame = randi_range(0,3)
	$Sprite2D.frame = sprite_frame

func _physics_process(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, DEACC * delta)
	
	position += velocity * delta
	
	if $BorderDetector.has_overlapping_bodies():
		disapearing = true
	
	elif velocity.length() < 0.1 or has_overlapping_bodies():
		stopped.emit(global_position, global_rotation, sprite_frame)
		queue_free()
	
	if disapearing:
		modulate.a -= 1. / 0.7 * delta
		if modulate.a <= 0: queue_free()
