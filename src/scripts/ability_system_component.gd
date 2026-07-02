extends Node
class_name MF_AbilitySystemComponent

signal ability_activated(ability_id: StringName)
signal effect_applied(effect: MF_GameplayEffect)

@export var attributes: MF_AttributeSet
@export var owned_abilities: Array[MF_GameAbility] = []

var _cooldowns: Dictionary = {}
var _tag_container: MF_GTagContainer


func _ready() -> void:
	if attributes == null:
		attributes = MF_AttributeSet.new()
	_ensure_tag_container()


func _ensure_tag_container() -> void:
	if _tag_container != null:
		return
	_tag_container = MF_GTagContainer.new()
	_tag_container.name = "MF_GTagContainer"
	add_child(_tag_container)


func can_activate(ability: MF_GameAbility) -> bool:
	_ensure_tag_container()
	if ability == null:
		return false
	if _cooldowns.get(ability.ability_id, 0.0) > Time.get_ticks_msec() / 1000.0:
		return false
	if attributes.stamina < ability.cost_stamina:
		return false
	for blocked in ability.blocked_tags:
		if _tag_container.has_tag(blocked):
			return false
	for required in ability.required_tags:
		if not _tag_container.has_tag(required):
			return false
	return true


func activate_ability_by_id(ability_id: StringName) -> bool:
	for ability in owned_abilities:
		if ability.ability_id == ability_id:
			return activate_ability(ability)
	return false


func activate_ability(ability: MF_GameAbility) -> bool:
	if not can_activate(ability):
		return false
	attributes.stamina -= ability.cost_stamina
	var now_sec: float = Time.get_ticks_msec() / 1000.0
	_cooldowns[ability.ability_id] = now_sec + ability.cooldown_sec
	for effect in ability.granted_effects:
		apply_effect(effect)
	emit_signal("ability_activated", ability.ability_id)
	return true


func apply_effect(effect: MF_GameplayEffect) -> void:
	_ensure_tag_container()
	if effect == null:
		return
	attributes.health = clamp(attributes.health + effect.health_delta, 0.0, attributes.max_health)
	attributes.damage += effect.damage_delta
	attributes.move_speed *= effect.speed_multiplier
	for tag in effect.tags:
		_tag_container.add_tag(tag, effect.stack_count)
	emit_signal("effect_applied", effect)


func add_owned_ability(ability: MF_GameAbility) -> void:
	if ability == null:
		return
	owned_abilities.append(ability)


func has_tag(tag: MF_GTag) -> bool:
	_ensure_tag_container()
	return _tag_container.has_tag(tag)


func remove_tag(tag: MF_GTag, stacks: int = 1) -> void:
	_ensure_tag_container()
	_tag_container.remove_tag(tag, stacks)


func add_tag(tag: MF_GTag, stacks: int = 1) -> void:
	_ensure_tag_container()
	_tag_container.add_tag(tag, stacks)
