extends MF_BaseVfxEntity

@onready var sparks: GPUParticles3D = %Sparks

func _on_activated() -> void:
	sparks.emitting = true


func _on_timer_timeout():
	deactivate_vfx()
