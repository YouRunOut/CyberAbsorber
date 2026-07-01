extends GameplayEffect
class_name GE_Heal

@export var heal_amount: float = 9.0


func _init():
	effect_mode = EffectMode.INSTANT
	health_delta = heal_amount


func set_heal_amount(value: float) -> GE_Heal:
	heal_amount = value
	health_delta = value
	return self
