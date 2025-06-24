class_name BloodParticle
extends CharacterBody2D

const DEACC = 500

signal stopped(pos: Vector2, rot: float)

func _physics_process(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, DEACC * delta)
	
	if move_and_slide() or velocity.length() < 0.1:
		stopped.emit(global_position, global_rotation)
		queue_free()
