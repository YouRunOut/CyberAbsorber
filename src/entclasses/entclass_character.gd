extends MF_BaseCombatant

@export var damage_effect: GameplayEffect

var ability_system_component: AbilitySystemComponent
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var direction: Vector3 = Vector3.ZERO
var SPEED: float = 0.0


func _ready() -> void:
	super._ready()
	if damage_effect == null:
		damage_effect = GE_Damage.new()


func initialize_character_gas(attribute_set: AttributeSet) -> void:
	if ability_system_component == null:
		ability_system_component = AbilitySystemComponent.new()
		ability_system_component.name = "AbilitySystemComponent"
		add_child(ability_system_component)
	if attribute_set:
		ability_system_component.attribute_sets = [attribute_set]
	_connect_attribute_signals()
	sync_hp_from_attributes()


func _connect_attribute_signals() -> void:
	if ability_system_component == null:
		return
	if not ability_system_component.attribute_changed.is_connected(_on_attribute_changed):
		ability_system_component.attribute_changed.connect(_on_attribute_changed)


func _on_attribute_changed(attribute_name: String, _old_value: float, _new_value: float, _effect_spec: GameplayEffectSpec) -> void:
	if attribute_name == "health" or attribute_name == "max_health":
		sync_hp_from_attributes()


func sync_hp_from_attributes() -> void:
	if ability_system_component == null:
		return
	var health_attr := ability_system_component.get_attribute("health")
	var max_health_attr := ability_system_component.get_attribute("max_health")
	if max_health_attr:
		max_hp = int(max_health_attr.current_value)
	if health_attr:
		hp = int(clampf(health_attr.current_value, 0.0, float(max_hp)))


func receive_gas_damage(amount: float, source: Node = null) -> void:
	if amount <= 0.0 or ability_system_component == null:
		return
	if damage_effect == null:
		damage_effect = GE_Damage.new()

	var source_asc: AbilitySystemComponent = null
	if source != null:
		source_asc = source.get_node_or_null("AbilitySystemComponent")

	if source_asc:
		ability_system_component.apply_gameplay_effect(damage_effect, source_asc, amount)
	else:
		ability_system_component.apply_gameplay_effect(damage_effect, ability_system_component, amount)

	sync_hp_from_attributes()


func get_current_health() -> float:
	if ability_system_component == null:
		return float(hp)
	var health_attr := ability_system_component.get_attribute("health")
	return health_attr.current_value if health_attr else float(hp)


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta


func move_towards_position(target_position: Vector3, move_speed: float) -> void:
	SPEED = move_speed
	direction = (target_position - global_position).normalized()
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED


func stop_movement() -> void:
	velocity.x = 0.0
	velocity.z = 0.0


func commit_movement() -> void:
	move_and_slide()
