extends Node
class_name SceneFlowManager

@export var first_level_path: String = "res://assets/scenes/locations/FirstLevel.tscn"
@export var second_level_path: String = "res://assets/scenes/locations/SecondLevel.tscn"


func load_first_level() -> void:
	get_tree().change_scene_to_file(first_level_path)


func load_second_level() -> void:
	get_tree().change_scene_to_file(second_level_path)


func restart_current_run() -> void:
	load_first_level()
