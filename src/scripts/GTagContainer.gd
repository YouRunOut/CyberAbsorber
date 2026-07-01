extends Node
class_name GTagContainer

signal tag_added(tag_name: StringName)
signal tag_removed(tag_name: StringName)
signal tag_stack_changed(tag_name: StringName, stack_count: int)

var _tag_stacks: Dictionary = {}


func add_tag(tag: GTag, stacks: int = 1) -> void:
	if tag == null or not tag.is_valid() or stacks <= 0:
		return
	var tag_name := tag.tag_name
	var prev_count: int = int(_tag_stacks.get(tag_name, 0))
	var new_count := prev_count + stacks
	_tag_stacks[tag_name] = new_count
	if prev_count == 0:
		emit_signal("tag_added", tag_name)
	emit_signal("tag_stack_changed", tag_name, new_count)


func remove_tag(tag: GTag, stacks: int = 1) -> void:
	if tag == null or not tag.is_valid() or stacks <= 0:
		return
	var tag_name := tag.tag_name
	var prev_count: int = int(_tag_stacks.get(tag_name, 0))
	if prev_count <= 0:
		return
	var new_count: int = int(max(prev_count - stacks, 0))
	if new_count == 0:
		_tag_stacks.erase(tag_name)
		emit_signal("tag_removed", tag_name)
	else:
		_tag_stacks[tag_name] = new_count
	emit_signal("tag_stack_changed", tag_name, new_count)


func has_tag(tag: GTag) -> bool:
	if tag == null or not tag.is_valid():
		return false
	return int(_tag_stacks.get(tag.tag_name, 0)) > 0


func has_all(tags: Array[GTag]) -> bool:
	for tag in tags:
		if not has_tag(tag):
			return false
	return true


func has_any(tags: Array[GTag]) -> bool:
	for tag in tags:
		if has_tag(tag):
			return true
	return false


func get_stack_count(tag: GTag) -> int:
	if tag == null or not tag.is_valid():
		return 0
	return int(_tag_stacks.get(tag.tag_name, 0))
