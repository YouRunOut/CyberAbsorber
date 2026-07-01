extends Node
class_name GuiManager

signal skill_tree_visibility_changed(is_open: bool)
signal hacking_visibility_changed(is_active: bool)

var _skill_tree_open := false
var _hacking_active := false


func set_skill_tree_open(is_open: bool) -> void:
	_skill_tree_open = is_open
	emit_signal("skill_tree_visibility_changed", is_open)


func set_hacking_active(is_active: bool) -> void:
	_hacking_active = is_active
	emit_signal("hacking_visibility_changed", is_active)


func is_skill_tree_open() -> bool:
	return _skill_tree_open


func is_hacking_active() -> bool:
	return _hacking_active
