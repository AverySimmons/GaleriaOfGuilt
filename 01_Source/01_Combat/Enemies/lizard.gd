extends Enemy

@onready var navigation = $NavigationAgent2D
@onready var ball_o_lightning : Area2D = $BallOLightning

func _ready() -> void:
	super._ready()
	type = "Lizard"

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
