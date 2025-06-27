extends Control

@onready var border: ColorRect = $Transform/Name/Border
@onready var background: Panel = $Transform/Background
@onready var description: Label = $Transform/Description
@onready var nametag: Label = $Transform/Name
@onready var sprite_2d: Sprite2D = $Transform/Icon/Sprite2D
@onready var icon: Panel = $Transform/Icon
@onready var button: Button = $Button
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	format(randi_range(0, 3))
	button.mouse_entered.connect(on_hover)
	button.mouse_exited.connect(stop_hover)
	button.pressed.connect(clicked)

func format(type: int):
	var back_style : StyleBoxFlat = background.get_theme_stylebox("panel")
	var icon_style : StyleBoxFlat = icon.get_theme_stylebox("panel")
	match type:
		0:
			background.material.set_shader_parameter("color", Vector3(1,0,0))
			
			back_style.bg_color = Color("53001e")
			
			icon_style.bg_color = Color("300001")
			
			border.color = Color("730021")
		
		1:
			background.material.set_shader_parameter("color", Vector3(1,1,1))
			
			back_style.bg_color = Color("571b1b")
			
			icon_style.bg_color = Color("59002b")
			
			border.color = Color("690033")
		
		2:
			background.material.set_shader_parameter("color", Vector3(1,0,0.9))
			
			back_style.bg_color = Color("240033")
			
			icon_style.bg_color = Color("300029")
			
			border.color = Color("4b0257")
		
		3:
			background.material.set_shader_parameter("color", Vector3(1,0,0.9))
			
			back_style.bg_color = Color("240087")
			
			icon_style.bg_color = Color("240043")
			
			border.color = Color("380d6e")
		
	nametag.text = "name"
	description.text = "description"
	# sprite_2d.texture = 
	
	icon.add_theme_stylebox_override("panel", icon_style)
	background.add_theme_stylebox_override("panel", back_style)

func on_hover():
	animation_player.play("hovered")

func stop_hover():
	animation_player.play("stop_hover")

func clicked():
	animation_player.play("fade_out")
	button.mouse_entered.disconnect(on_hover)
	button.mouse_exited.disconnect(stop_hover)
