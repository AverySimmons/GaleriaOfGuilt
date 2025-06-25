@tool
extends BTAction

var enemy : Enemy
var player_on_right : bool
var facing_right : bool

## variables at the top

func _generate_name() -> String:
	return 'turn to face player if needed'
	
func _setup() -> void:
	
	
	enemy = agent as Enemy
	
func _enter() -> void:
	player_on_right = false
	facing_right = false
	
func _tick(delta: float) -> Status:
	if enemy.global_position.x <= GameData.player.global_position.x: #if player is to the right
		player_on_right = true
	if enemy.sprite.scale.x > 0:
		facing_right = true
	
	#print('start of tick')
	#print('player_on_right: ', player_on_right)
	#print('facing_right: ', facing_right)
	if player_on_right:
		if !facing_right: #not facing right
			enemy.sprite.scale.x *= -1
	else: #player to the left
		if facing_right:
			enemy.sprite.scale.x *= -1
	
	return SUCCESS
	
## think about helper functions down here
