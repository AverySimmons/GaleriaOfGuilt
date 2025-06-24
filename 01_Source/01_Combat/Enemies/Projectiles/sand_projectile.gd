extends CharacterBody2D

func _physics_process(delta: float) -> void:
	var collided = move_and_slide()
	if collided:
		die()
		
func die() -> void:
	queue_free()
