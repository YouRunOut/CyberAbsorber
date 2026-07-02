extends Node
class_name QuiltModule

signal quilt_tick
signal quilt_target_changed(target: Node3D)
signal quilt_ready

var ability_component: AbilitySystemComponent
var owner_area: Area3D
var charge_value: float = 0.0
var nearest_enemy: Node3D = null
var quilt_ready_pending: bool = false
var quilt_ability_id: StringName = StringName("GA_Quilt")
var quilt_ready_tag: GTag = GTag.new(StringName("GTag_QUILT_READY"))


func tick() -> void:
	emit_signal("quilt_tick")


func configure(component: AbilitySystemComponent, quilt_area: Area3D) -> void:
	ability_component = component
	owner_area = quilt_area


func update_target(origin: Vector3) -> void:
	if owner_area == null:
		return
	var enemies = owner_area.get_overlapping_bodies()
	nearest_enemy = null
	if enemies.is_empty():
		emit_signal("quilt_target_changed", nearest_enemy)
		return

	nearest_enemy = enemies[0]
	for enemy in enemies:
		if enemy.global_position.distance_to(origin) < nearest_enemy.global_position.distance_to(origin):
			nearest_enemy = enemy
	emit_signal("quilt_target_changed", nearest_enemy)


func tick_charge(quilt_pressed: bool) -> void:
	if ability_component == null or ability_component.attributes == null:
		return
	var attrs = ability_component.attributes
	if quilt_pressed:
		if attrs.quilt_hold_mode_unlocked:
			charge_value += attrs.quilt_charge_gain_hold_per_sec
		else:
			charge_value += attrs.quilt_charge_gain_tap
	else:
		charge_value = max(charge_value - attrs.quilt_decay_per_tick, 0.0)

	if charge_value >= attrs.quilt_charge_max:
		charge_value = 0.0
		if ability_component:
			ability_component.activate_ability_by_id(quilt_ability_id)
		quilt_ready_pending = ability_component != null and ability_component.has_tag(quilt_ready_tag)
		emit_signal("quilt_ready")


func consume_ready_for_target(target: Node3D) -> bool:
	if target != null and target == nearest_enemy and ability_component and ability_component.has_tag(quilt_ready_tag):
		ability_component.remove_tag(quilt_ready_tag)
		quilt_ready_pending = false
		return true
	return false
