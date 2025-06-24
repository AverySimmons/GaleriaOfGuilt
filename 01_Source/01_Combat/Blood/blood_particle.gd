class_name BloodParticle
extends Area2D

const DEACC = 2500

signal stopped(pos: Vector2, rot: float)

var velocity = Vector2.ZERO
var disapearing = false

func _physics_process(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, DEACC * delta)
	
	position += velocity * delta
	
	if $BorderDetector.has_overlapping_bodies():
		disapearing = true
	
	elif velocity.length() < 0.1 or has_overlapping_bodies():
		stopped.emit(global_position, global_rotation)
		queue_free()
	
	if disapearing:
		modulate.a -= 1. / 0.25 * delta
		if modulate.a <= 0: queue_free()
