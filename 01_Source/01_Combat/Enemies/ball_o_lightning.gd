extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@onready var parent: CharacterBody2D = get_parent()

var is_active: bool = false
var active_time: float = 0.5
var active_timer: float
