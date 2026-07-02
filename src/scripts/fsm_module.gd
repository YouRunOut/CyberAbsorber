extends Node
class_name MF_FsmModule

@export var current_state: StringName = &"idle"
signal state_changed(new_state: StringName)


func set_state(new_state: StringName) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	emit_signal("state_changed", new_state)
