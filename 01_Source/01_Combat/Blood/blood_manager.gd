class_name BloodManager
extends MultiMeshInstance2D

var blood_scene = preload("res://01_Source/01_Combat/Blood/blood_particle.tscn")

func _ready() -> void:
	multimesh.instance_count = 10000

func spawn():
	SignalBus.spawn_blood.connect(spawn_blood_particle)

func despawn():
	SignalBus.spawn_blood.disconnect(spawn_blood_particle)
	for child in get_children():
		if child is BloodParticle:
			child.queue_free()

func add_blood(pos: Vector2, rot: float, frame: int) -> void:
	var mm := multimesh
	var index = mm.visible_instance_count
	
	var custom_data = Color(float(frame) / 4., 0, 0);
	
	mm.set_instance_transform_2d(index, Transform2D(rot, pos))
	mm.set_instance_custom_data(index, custom_data)
	mm.visible_instance_count += 1

func spawn_blood_particle(pos: Vector2, vel: Vector2) -> BloodParticle:
	var new_blood: BloodParticle = blood_scene.instantiate()
	new_blood.global_position = pos
	new_blood.global_rotation = randf_range(-PI, PI)
	new_blood.velocity = vel
	new_blood.stopped.connect(add_blood)
	add_child(new_blood)
	return new_blood
