extends Node
class_name HealthComponent

signal health_changed(current_hp: int, max_hp: int)
signal damaged(amount: int)
signal died

@export var max_hp: int = 100
@export var start_hp: int = 100
@export var ability_component: AbilitySystemComponent

var current_hp: int


func _ready() -> void:
	if ability_component and ability_component.attributes:
		max_hp = int(ability_component.attributes.max_health)
		current_hp = int(clamp(ability_component.attributes.health, 0.0, ability_component.attributes.max_health))
		if not ability_component.effect_applied.is_connected(_on_effect_applied):
			ability_component.effect_applied.connect(_on_effect_applied)
	else:
		current_hp = clamp(start_hp, 0, max_hp)
	emit_signal("health_changed", current_hp, max_hp)


func reset_health() -> void:
	current_hp = max_hp
	_sync_to_ability()
	emit_signal("health_changed", current_hp, max_hp)


func heal(amount: int) -> void:
	if amount <= 0:
		return
	current_hp = min(current_hp + amount, max_hp)
	_sync_to_ability()
	emit_signal("health_changed", current_hp, max_hp)


func take_damage(amount: int) -> void:
	if amount <= 0:
		return
	current_hp = max(current_hp - amount, 0)
	_sync_to_ability()
	emit_signal("damaged", amount)
	emit_signal("health_changed", current_hp, max_hp)
	if current_hp == 0:
		emit_signal("died")


func _sync_to_ability() -> void:
	if ability_component and ability_component.attributes:
		ability_component.attributes.max_health = max_hp
		ability_component.attributes.health = current_hp


func _on_effect_applied(_effect: GameplayEffect) -> void:
	if ability_component == null or ability_component.attributes == null:
		return
	max_hp = int(ability_component.attributes.max_health)
	current_hp = int(clamp(ability_component.attributes.health, 0.0, ability_component.attributes.max_health))
	var combatant_owner := get_parent()
	if combatant_owner is BaseCombatant:
		combatant_owner.hp = current_hp
	emit_signal("health_changed", current_hp, max_hp)
	if current_hp == 0:
		emit_signal("died")
