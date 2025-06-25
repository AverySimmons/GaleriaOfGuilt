@tool
extends BTAction

## variables at the top

func _generate_name() -> String:
	return 'Charge through the player location, syncronized with others'
	
func _setup() -> void:
	pass
	
func _enter() -> void:
	pass
	
func _tick(delta: float) -> Status:
	return SUCCESS
	
## think about helper functions down here
