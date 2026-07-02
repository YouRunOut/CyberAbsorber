extends Resource
class_name MF_GTag

@export var tag_name: StringName = StringName("GTag_UNSET")


func _init(initial_name: StringName = StringName("GTag_UNSET")) -> void:
	tag_name = initial_name


func is_valid() -> bool:
	var tag_text := str(tag_name)
	var regex := RegEx.new()
	regex.compile("^GTag_[A-Z0-9_]+$")
	return regex.search(tag_text) != null


func set_tag_name(value: StringName) -> MF_GTag:
	tag_name = value
	return self
