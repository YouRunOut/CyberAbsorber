extends Node
class_name CoverModule

signal cover_changed(cover_position: Vector3, cover_type: int)

var current_cover_position: Vector3
var current_cover_type: int = 0


func set_cover(cover_position: Vector3, cover_type: int) -> void:
	current_cover_position = cover_position
	current_cover_type = cover_type
	emit_signal("cover_changed", cover_position, cover_type)
