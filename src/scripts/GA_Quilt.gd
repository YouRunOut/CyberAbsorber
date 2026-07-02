extends MF_GameAbility
class_name MF_GA_Quilt


func _init():
	ability_id = StringName("MF_GA_Quilt")
	cooldown_sec = 0.0
	cost_stamina = 0.0
	granted_effects = [MF_GE_QuiltReady.new()]
