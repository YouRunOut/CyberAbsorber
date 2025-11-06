extends Node3D

@onready var label_3d = $Label3D
@onready var screen = $PC/Screen


func _ready():
	label_3d.visible = false
	screen.visible = false


func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		label_3d.visible = true
		screen.visible = true
		#body.ShowActionButton():


func _on_area_3d_body_exited(body):
	if body.is_in_group("Player"):
		label_3d.visible = false
		screen.visible = false
