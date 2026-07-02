extends Node
class_name MF_SaveStateRegistry

var _saveables: Dictionary = {}


func register_saveable(entity_id: StringName, node: Node) -> void:
	_saveables[entity_id] = node


func unregister_saveable(entity_id: StringName) -> void:
	_saveables.erase(entity_id)


func get_saveables() -> Dictionary:
	return _saveables
