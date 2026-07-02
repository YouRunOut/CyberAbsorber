extends Node
class_name MF_PerceptionModule

signal target_changed(target: Node3D)

var current_target: Node3D


func set_target(target: Node3D) -> void:
	current_target = target
	emit_signal("target_changed", current_target)
