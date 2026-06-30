extends TextureButton
@onready var streak_control
@onready var input_sound = $InputSound
@onready var create_sound = $CreateSound


const TRIGGER = preload("res://Textures/Cells/Trigger.png")

const ACCEPT = preload("res://Sounds/GUI/Hack/Accept.wav")

var trigger : bool = false


func _ready():
	create_sound.play()
	streak_control = get_parent().get_parent().get_parent()
	if self.get_name() == "File-Сell": grab_focus()
	
	if trigger:
		input_sound.set_stream(ACCEPT)
		set_texture_hover(TRIGGER)
		set_texture_focused(TRIGGER)
		set_texture_disabled(TRIGGER)


func _on_pressed():
	input_sound.play()
	if trigger:
		streak_control.create_step()
		streak_control.iter += 1
