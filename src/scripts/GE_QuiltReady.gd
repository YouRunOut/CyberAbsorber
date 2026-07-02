extends GameplayEffect
class_name GE_QuiltReady


func _init():
	effect_mode = EffectMode.INSTANT
	tags = [GTag.new(StringName("GTag_QUILT_READY"))]
