class_name BloodManager
extends MultiMeshInstance2D

var blood_scene = preload("res://01_Source/01_Combat/Blood/blood_particle.tscn")

func add_blood(pos: Vector2, rot: float) -> void:
	var mm := multimesh
	var index = mm.visible_instance_count
	
	mm.set_instance_transform_2d(index, Transform2D(rot, pos))
	mm.visible_instance_count += 1

func spawn_blood_particle(pos: Vector2, rot: float, vel: Vector2) -> BloodParticle:
	var new_blood: BloodParticle = blood_scene.instantiate()
	new_blood.global_position = pos
	new_blood.global_rotation = rot
	new_blood.velocity = vel
	new_blood.stopped.connect(add_blood)
	add_child(new_blood)
	return new_blood

func spawn_blood_clump(pos: Vector2, vel: Vector2):
	for i in randi_range(3, 5):
		var offset = Vector2.from_angle(randf_range(-PI, PI)) * 3
		spawn_blood_particle(pos + offset, randf_range(-PI, PI), vel)
