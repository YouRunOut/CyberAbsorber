extends Node3D

@onready var timer: Timer = %Timer

const SPEED = 45.0
@export var damage: int = 15


func _physics_process(delta):
	position += transform.basis.x * SPEED * delta

func destroy():
	queue_free()

func _on_timer_timeout():
	destroy()


func _on_area_3d_body_entered(body):
	if body.is_in_group("Player") or body.is_in_group("Enemy_human"):
		var battle_manager = Main.get_battle_manager()
		if battle_manager:
			battle_manager.apply_damage(body, damage, self)
		else:
			var combatant := body as MF_BaseCombatant
			if combatant:
				combatant.get_damage(damage)
		destroy()
