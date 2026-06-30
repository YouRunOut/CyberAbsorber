extends Node3D

@onready var timer: Timer = %Timer

const SPEED = 45.0


func _physics_process(delta):
	position += transform.basis.x * SPEED * delta

func destroy():
	queue_free()

func _on_timer_timeout():
	destroy()


func _on_area_3d_body_entered(body):
	if body.has_method("get_damage"):
		body.get_damage()
		destroy()
