extends Sprite2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var enemy: Enemy
var entities_node: Node2D
var spawn_time: float = 1

func _ready() -> void:
	animation_player.speed_scale = 1 / spawn_time
	get_tree().create_timer(spawn_time).timeout.connect(spawn, ConnectFlags.CONNECT_DEFERRED)

func spawn() -> void:
	enemy.global_position = global_position
	entities_node.add_child(enemy)
