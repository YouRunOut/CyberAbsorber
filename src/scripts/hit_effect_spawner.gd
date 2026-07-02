extends Node3D
class_name MF_HitEffectSpawner

@export var flesh_hit_scene: PackedScene
@export var material_hit_scene: PackedScene


func spawn_hit_point(hit_cords: Vector3, is_flesh: bool) -> void:
	var scene_to_spawn: PackedScene = flesh_hit_scene if is_flesh else material_hit_scene
	if scene_to_spawn == null:
		return
	var hit_point_inst = scene_to_spawn.instantiate()
	hit_point_inst.global_position = hit_cords
	get_parent().add_child(hit_point_inst)
