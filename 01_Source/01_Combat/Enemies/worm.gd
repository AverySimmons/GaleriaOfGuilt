extends Enemy

@onready var navigation = $NavigationAgent2D
@onready var mouth_pos = $Sprite2D/Marker2D

func _init() -> void:
	type = "Worm"

func _ready() -> void:
	super._ready()
	move_speed = 250
	if upgraded:
		AudioData.play_sound("enemy_transform", $EnemyTransform)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	

	
