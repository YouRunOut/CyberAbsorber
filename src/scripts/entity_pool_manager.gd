extends Node
class_name MF_EntityPoolManager

var _pool: Dictionary = {}


func warm_pool(pool_id: StringName, scene: PackedScene, amount: int, parent: Node) -> void:
	if not _pool.has(pool_id):
		_pool[pool_id] = []
	for i in amount:
		var instance = scene.instantiate()
		_deactivate_instance(instance)
		parent.add_child(instance)
		_pool[pool_id].append(instance)


func spawn(pool_id: StringName, scene: PackedScene, parent: Node, at_position: Vector3 = Vector3.ZERO) -> Node:
	if not _pool.has(pool_id):
		_pool[pool_id] = []

	var instance = null
	for candidate in _pool[pool_id]:
		if not candidate.visible:
			instance = candidate
			break

	if instance == null:
		instance = scene.instantiate()
		parent.add_child(instance)
		_pool[pool_id].append(instance)

	instance.global_position = at_position
	_activate_instance(instance)
	return instance


func despawn(pool_id: StringName, instance: Node) -> void:
	if instance == null:
		return
	_deactivate_instance(instance)
	if _pool.has(pool_id) and not (_pool[pool_id].has(instance)):
		_pool[pool_id].append(instance)


func _activate_instance(instance: Node) -> void:
	if instance is CanvasItem:
		instance.visible = true
	elif instance is Node3D:
		instance.visible = true
	instance.set_process(true)
	instance.set_physics_process(true)


func _deactivate_instance(instance: Node) -> void:
	if instance is CanvasItem:
		instance.visible = false
	elif instance is Node3D:
		instance.visible = false
	instance.set_process(false)
	instance.set_physics_process(false)
