extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var is_active: bool = false
var active_time: float = 1.
var active_timer: float = 1.
var damage : float = 15

func _ready() -> void:
	#AudioData.play_sound("lightning_charge", $SpawnSound)
	await get_tree().create_timer(active_time, false).timeout
	$AnimationPlayer.play("ball_o_lightning_damaging")
	#AudioData.play_sound("lightning_explode", $ExplodeSound)
	await $AnimationPlayer.animation_finished
	call_deferred("queue_free")

func _physics_process(delta: float) -> void:
	if not monitoring: return
	var overlapping_areas = get_overlapping_areas()
	if overlapping_areas:
		var player : Player = overlapping_areas[0].owner
		player.take_damage(damage)
