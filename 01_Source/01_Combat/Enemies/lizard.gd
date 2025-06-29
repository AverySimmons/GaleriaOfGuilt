extends Enemy

@onready var navigation = $NavigationAgent2D

var lightning_attack_active : bool = false
var lightning_attack_visible : bool = false
var lightning_position : Vector2 
var lightning_delay : float = 0.8
var lightning_delay_timer : float = 0


func _ready() -> void:
	super._ready()
	type = "Lizard"

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
		
	
