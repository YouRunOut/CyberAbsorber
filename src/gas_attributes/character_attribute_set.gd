@tool
class_name CharacterAttributeSet extends BaseEntityAttributeSet

var stamina: AttributeData = AttributeData.new(100.0)
var max_stamina: AttributeData = AttributeData.new(100.0)
var regen_stamina: AttributeData = AttributeData.new(10.0)
var damage_multiplier: AttributeData = AttributeData.new(1.0)
var move_speed: AttributeData = AttributeData.new(2.5)

func pre_attribute_change(attribute_name: String, proposed_value: float) -> float:
	match attribute_name:
		"stamina":
			return clamp(proposed_value, 0.0, max_stamina.current_value)
		"max_stamina":
			return maxf(1.0, proposed_value)
		"regen_stamina":
			return maxf(0.0, proposed_value)
		"damage_multiplier":
			return maxf(0.0, proposed_value)
		"move_speed":
			return maxf(0.0, proposed_value)
	return super.pre_attribute_change(attribute_name, proposed_value)
