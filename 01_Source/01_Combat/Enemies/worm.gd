extends Enemy

@onready var navigation = $NavigationAgent2D
@onready var sprite = $WormSprite

var going_up: bool = false
var going_down: bool = false

var Animations : AnimationPlayer

var move_state = true

var bullet_node : Node2D


func _ready() -> void:
	super._ready()
	
	move_speed = 250

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if velocity.length() > 1:
		print('movement animations')
		select_movement_animations()
		
	
	
	#right - 0
	#-pi/4 topside 45
	#pi/4 bot side 45
	
func select_movement_animations():
	if facing_direction.angle() > -3/4. * PI && facing_direction.angle() < -1/4. * PI: #going hard upward
		going_up = true
	else: 
		going_up = false
	
	if facing_direction.angle() > 1/4. * PI && facing_direction.angle() < 3/4. * PI: #going hard downward
		going_down = true
	else: 
		going_down = false
	
	if going_up:
		$Animations.play('move_up')
	elif going_down:
		$Animations.play('move_down')
	elif facing_direction.x > 0: #going right
		if sprite.scale.x < 0:
			sprite.scale.x *= -1
		$Animations.play('walk')
	else: #going left
		if sprite.scale.x > 0:
			sprite.scale.x *= -1
		$Animations.play('walk')
		
