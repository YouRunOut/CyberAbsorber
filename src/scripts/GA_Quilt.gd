extends GameAbility
class_name GA_Quilt


func _init():
	ability_id = StringName("GA_Quilt")
	cooldown_sec = 0.0
	cost_stamina = 0.0
	granted_effects = [GE_QuiltReady.new()]
