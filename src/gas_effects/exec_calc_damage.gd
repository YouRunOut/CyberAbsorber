extends GameplayExecutionCalculation
class_name ExecCalc_Damage


const DESTRUCTIBLE_TAG: StringName = &"State.Destructible"
const HEALTH_ATTR: String = "health"
const RESIST_ATTR: String = "resistance"


func execute(spec: GameplayEffectSpec, target_asc: AbilitySystemComponent) -> Dictionary:
	if target_asc == null:
		return {}

	var incoming_damage: float = maxf(spec.level, 0.0)
	if incoming_damage <= 0.0:
		return {}

	var resistance := 0.0
	var resistance_attr := target_asc.get_attribute(RESIST_ATTR)
	if resistance_attr:
		resistance = clampf(resistance_attr.current_value, 0.0, 0.95)

	var final_damage := incoming_damage * (1.0 - resistance)
	if target_asc.has_tag(DESTRUCTIBLE_TAG):
		final_damage *= 4.0

	if final_damage <= 0.0:
		return {}

	return {
		HEALTH_ATTR: -final_damage
	}
