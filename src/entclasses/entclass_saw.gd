extends Node3D

@onready var animation: AnimationPlayer = %AnimationPlayer


func _ready():
	animation.play("worked")
