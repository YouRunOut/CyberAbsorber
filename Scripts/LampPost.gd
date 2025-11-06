extends Node3D
@onready var audio = $Lamp/AudioStreamPlayer3D

@onready var glass = $Lamp/glass
@onready var sparks = $Lamp/Sparks
var destroyed = false

func destroy():
	if not destroyed:
		audio.playing = true
		sparks.emitting = true
		glass.visible = false

func _on_area_3d_area_entered(area):
	if area.is_in_group("Bullet"):
		destroy()
