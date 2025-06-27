extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@onready var parent: CharacterBody2D = get_parent()

var is_active: bool = false
var active_time: float = 0.5
var active_timer: float
var damage : float = 20

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	#collision_shape_2d.global_position = GameData.player.global_position #why doesn't this work??
	
	if parent.lightning_attack_active:
		
		var overlapping_areas = get_overlapping_areas()
		if overlapping_areas:
			
			var player : Player = overlapping_areas[0].owner
			player.take_damage(damage)
