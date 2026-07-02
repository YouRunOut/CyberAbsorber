extends Node
class_name MF_SaveLoadManager

@export var save_path: String = "user://savegame_v1.json"

var save_registry: Node
var serializer: Node


func configure(registry: Node, serializer_node: Node) -> void:
	save_registry = registry
	serializer = serializer_node


func save_game(main_state: Node) -> bool:
	if serializer == null:
		return false
	var snapshot: Dictionary = serializer.build_snapshot(main_state, save_registry)
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(snapshot))
	return true


func load_game() -> Dictionary:
	if not FileAccess.file_exists(save_path):
		return {}
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		return {}
	var content := file.get_as_text()
	var parsed = JSON.parse_string(content)
	return parsed if parsed is Dictionary else {}
