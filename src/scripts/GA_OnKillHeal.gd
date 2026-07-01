extends GameAbility
class_name GA_OnKillHeal

@export var heal_amount: float = 9.0


func _init():
	ability_id = StringName("GA_OnKillHeal")
	cooldown_sec = 0.0
	cost_stamina = 0.0
	granted_effects = [GE_Heal.new().set_heal_amount(heal_amount)]


func set_heal_amount(value: float) -> GA_OnKillHeal:
	heal_amount = value
	granted_effects = [GE_Heal.new().set_heal_amount(value)]
	return self
