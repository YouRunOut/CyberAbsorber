extends Node
class_name MF_MovementModule

signal movement_tick(delta: float)


func tick(delta: float) -> void:
	emit_signal("movement_tick", delta)
