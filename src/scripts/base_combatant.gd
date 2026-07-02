extends CharacterBody3D
class_name MF_BaseCombatant

signal combatant_died
signal combatant_damaged(amount: int)

@export var max_hp: int = 100
@export var use_main_player_hp_bridge: bool = false

var hp: int = 100
var health_component: MF_HealthComponent


func _ready() -> void:
	if health_component == null:
		health_component = get_node_or_null("MF_HealthComponent")
	if health_component:
		hp = health_component.current_hp
	else:
		hp = max_hp


func take_damage(amount: int, _source = null) -> void:
	if amount <= 0:
		return
	if health_component:
		health_component.take_damage(amount)
		hp = health_component.current_hp
	else:
		hp = max(hp - amount, 0)
	emit_signal("combatant_damaged", amount)
	after_damage(amount)
	if hp == 0:
		on_death()


func get_damage(damage: int = 0) -> void:
	take_damage(damage)


func after_damage(_amount: int) -> void:
	pass


func on_death() -> void:
	emit_signal("combatant_died")
