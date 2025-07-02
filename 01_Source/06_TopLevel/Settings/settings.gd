extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var resume_button: Sprite2D = $Sprite2D/ResumeButton
@onready var quit_button: Sprite2D = $Sprite2D/QuitButton

signal closed()

func close() -> void:
	$ButtonClick.play()
	animation_player.play("close")
	await animation_player.animation_finished
	
	closed.emit()
	call_deferred("queue_free")

func _on_resume_button_mouse_entered() -> void:
	resume_button.modulate = Color(1.1,1.1,1.1)
	$ButtonHover.play()

func _on_resume_button_mouse_exited() -> void:
	resume_button.modulate = Color(1,1,1)

func _on_quit_button_pressed() -> void:
	$ButtonClick.play()
	await $ButtonClick.finished
	get_tree().quit()

func _on_quit_button_mouse_entered() -> void:
	quit_button.modulate = Color(1.1,1.1,1.1)
	$ButtonHover.play()

func _on_quit_button_mouse_exited() -> void:
	quit_button.modulate = Color(1,1,1)
