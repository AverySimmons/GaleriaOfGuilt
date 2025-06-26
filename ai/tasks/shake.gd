@tool
extends BTAction

## variables at the top

func _generate_name() -> String:
	return 'shake in anticipation for attack'
	
func _setup() -> void:
	pass
	
func _enter() -> void:
	pass
	
func _tick(delta: float) -> Status:
	#use joey's shake component here
	return SUCCESS
	
## think about helper functions down here
