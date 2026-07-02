extends MF_GameplayEffect
class_name MF_GE_QuiltReady


func _init():
	effect_mode = EffectMode.INSTANT
	tags = [MF_GTag.new(StringName("GTag_QUILT_READY"))]
