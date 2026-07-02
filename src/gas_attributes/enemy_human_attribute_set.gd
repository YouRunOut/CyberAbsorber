@tool
class_name EnemyHumanAttributeSet
extends CharacterAttributeSet


func _init() -> void:
	max_health.base_value = 100.0
	health.base_value = 100.0
	stamina.base_value = 80.0
	max_stamina.base_value = 80.0
	regen_stamina.base_value = 8.0
	resistance.base_value = 0.1
	move_speed.base_value = 2.5
	damage_multiplier.base_value = 1.0
