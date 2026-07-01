extends Node3D
class_name BaseVfxEntity

@export var life_time_sec: float = 0.8
@export var auto_start: bool = true

var _life_timer: SceneTreeTimer


func _ready() -> void:
	if auto_start:
		activate_vfx()


func activate_vfx() -> void:
	visible = true
	_on_activated()
	if life_time_sec > 0:
		_life_timer = get_tree().create_timer(life_time_sec)
		_life_timer.timeout.connect(_on_life_timeout)


func reset_vfx() -> void:
	_on_reset()


func deactivate_vfx() -> void:
	_on_deactivated()
	queue_free()


func _on_activated() -> void:
	pass


func _on_reset() -> void:
	pass


func _on_deactivated() -> void:
	pass


func _on_life_timeout() -> void:
	deactivate_vfx()
