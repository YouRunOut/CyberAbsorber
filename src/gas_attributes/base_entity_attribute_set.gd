## An extended class for the attribute module: BaseEntity 
##
## @meta_addon: GodotGAS 1.0
## @meta_author: YulRun (https://YulRun.Dev) & 'Your Name Here'
## @meta_license: MIT (Default)

@tool
class_name BaseEntityAttributeSet extends AttributeSet

var health: AttributeData = AttributeData.new(100.0)
var max_health: AttributeData = AttributeData.new(100.0)
var resistance: AttributeData = AttributeData.new(0.0)


## The safety pipeline: Clamps stats before they are officially changed.
func pre_attribute_change(attribute_name: String, proposed_value: float) -> float:
	match attribute_name:
		"health":
			return clamp(proposed_value, 0.0, max_health.current_value)
		"max_health":
			return maxf(1.0, proposed_value)
		"resistance":
			return clampf(proposed_value, 0.0, 0.95)

	return proposed_value
