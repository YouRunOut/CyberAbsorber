extends Node
class_name MF_BattleManager

signal damage_routed(target: Node, amount: int, source: Node)
signal combatant_died(combatant: Node)


func apply_damage(target: Node, amount: int, source: Node = null) -> void:
	if target == null:
		return
	if amount <= 0:
		return

	if target.has_method("receive_gas_damage"):
		target.receive_gas_damage(float(amount), source)
		emit_signal("damage_routed", target, amount, source)
		return

	var combatant := target as MF_BaseCombatant
	if combatant == null:
		return
	combatant.get_damage(amount)
	emit_signal("damage_routed", target, amount, source)


func notify_death(combatant: Node) -> void:
	emit_signal("combatant_died", combatant)
