extends Enemy

@onready var navigation = $NavigationAgent2D
@onready var mouth_pos = $Sprite2D/Marker2D



func _ready() -> void:
	super._ready()
	type = "Worm"
	move_speed = 250

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	

	
