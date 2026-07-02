extends Node3D
class_name BaseEntity

signal entity_activated
signal entity_deactivated

@export var entity_id: StringName


func activate_entity() -> void:
	visible = true
	set_process(true)
	set_physics_process(true)
	emit_signal("entity_activated")


func deactivate_entity() -> void:
	visible = false
	set_process(false)
	set_physics_process(false)
	emit_signal("entity_deactivated")


func build_save_state() -> Dictionary:
	return {
		"position": global_position
	}
