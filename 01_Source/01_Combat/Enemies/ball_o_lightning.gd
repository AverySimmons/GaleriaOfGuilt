extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var is_active: bool = false
var active_time: float = 0.5
var active_timer: float = 0.5
var damage : float = 1

func _ready() -> void:
	await get_tree().create_timer(active_time).timeout
	$AnimationPlayer.play("ball_o_lightning_damaging")
	await $AnimationPlayer.animation_finished
	call_deferred("queue_free")

func _physics_process(delta: float) -> void:
	if not monitoring: return
	var overlapping_areas = get_overlapping_areas()
	if overlapping_areas:
		var player : Player = overlapping_areas[0].owner
		print("HIT")
		player.take_damage(damage)
