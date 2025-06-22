extends Enemy

@onready var navigation = $NavigationAgent2D
@onready var sprite = $WormSprite


func _ready() -> void:
	super._ready()
	
	move_speed = 300

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	select_movement_animations()
	
	#right - 0
	#-pi/4 topside 45
	#pi/4 bot side 45
	
func select_movement_animations():
	pass
