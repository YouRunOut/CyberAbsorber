extends Node3D
@onready var life_timer = $LifeTimer

@onready var blood = $Blood

var blast

func _ready():
	blast = false
	blood.emitting = true
	blood.draw_pass_1.size.y = 1

func _physics_process(delta):
	if blast:
		if blood.draw_pass_1.size.y != 0.1:
			blood.draw_pass_1.size.y = lerp(blood.draw_pass_1.size.y, 0.1, delta*10)

func _on_life_timer_timeout():
	blast = true

func _on_timer_timeout():
	queue_free()
