extends CharacterBody2D

func _physics_process(delta: float) -> void:
	var collided = move_and_slide() #core movement
	if collided:
		die()
	
	#deal damage to player
	var overlapping_areas = $Hitbox.get_overlapping_areas()
	if overlapping_areas:
		var player : Player = overlapping_areas[0].owner
		player.take_damage(10)
		die()
		
func die() -> void: #this could be polished
	queue_free()
