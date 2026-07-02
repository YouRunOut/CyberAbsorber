extends Node
class_name BattleManager

signal damage_routed(target: Node, amount: int, source: Node)
signal combatant_died(combatant: Node)


func apply_damage(target: Node, amount: int, source: Node = null) -> void:
	if target == null:
		return
	var combatant := target as BaseCombatant
	if combatant == null:
		return
	combatant.get_damage(amount)
	emit_signal("damage_routed", target, amount, source)


func notify_death(combatant: Node) -> void:
	emit_signal("combatant_died", combatant)
