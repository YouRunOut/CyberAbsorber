extends TextureButton
@export var trigger_texture: Texture2D
@export var accept_sound: AudioStream
@export var decline_sound: AudioStream

@onready var input_sound: AudioStreamPlayer = %InputSound
@onready var create_sound: AudioStreamPlayer = %CreateSound

var streak_control: Control

var trigger : bool = false


func _ready():
	create_sound.play()
	streak_control = get_parent().get_parent().get_parent()
	if self.get_name() == "File-Сell": grab_focus()
	
	if trigger and accept_sound and trigger_texture:
		input_sound.set_stream(accept_sound)
		set_texture_hover(trigger_texture)
		set_texture_focused(trigger_texture)
		set_texture_disabled(trigger_texture)


func _on_pressed():
	input_sound.play()
	if trigger:
		streak_control.create_step()
		streak_control.iter += 1
