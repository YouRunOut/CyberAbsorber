extends Node
class_name GameManager

signal game_started
signal game_restarted
signal level_completed(next_level_path: String)

@export var first_level_path: String = "res://assets/scenes/locations/FirstLevel.tscn"
@export var second_level_path: String = "res://assets/scenes/locations/SecondLevel.tscn"


func start_game() -> void:
	emit_signal("game_started")


func restart_game() -> void:
	emit_signal("game_restarted")


func complete_level(next_level: String) -> void:
	emit_signal("level_completed", next_level)
