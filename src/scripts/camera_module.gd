extends Node
class_name CameraModule

signal camera_tick(delta: float)


func tick(delta: float) -> void:
	emit_signal("camera_tick", delta)
