extends Node3D

@onready var sparks = $Sparks

var blast

func _ready():
	sparks.emitting = true

func _on_timer_timeout():
	queue_free()
