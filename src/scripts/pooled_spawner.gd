extends Node3D
class_name MF_PooledSpawner

@export var pool_id: StringName
@export var scene: PackedScene
@export var prewarm_amount: int = 0
@export var spawn_parent_path: NodePath

@onready var _spawn_parent: Node = get_node_or_null(spawn_parent_path) if spawn_parent_path != NodePath("") else get_parent()


func _ready() -> void:
	if Engine.has_singleton("Main"):
		pass
	var pool = Main.get_entity_pool_manager()
	if pool and scene and prewarm_amount > 0:
		pool.warm_pool(pool_id, scene, prewarm_amount, _spawn_parent)


func spawn_one(at_position: Vector3) -> Node:
	var pool = Main.get_entity_pool_manager()
	if pool and scene:
		return pool.spawn(pool_id, scene, _spawn_parent, at_position)
	return null
