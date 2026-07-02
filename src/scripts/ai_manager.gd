extends Node
class_name MF_AiManager

signal enemy_registered(enemy: Node)
signal enemy_unregistered(enemy: Node)

var enemies: Array = []


func register_enemy(enemy: Node) -> void:
	if enemy in enemies:
		return
	enemies.append(enemy)
	emit_signal("enemy_registered", enemy)


func unregister_enemy(enemy: Node) -> void:
	if not (enemy in enemies):
		return
	enemies.erase(enemy)
	emit_signal("enemy_unregistered", enemy)


func get_alive_enemies() -> Array:
	return enemies.filter(func(e): return is_instance_valid(e))
