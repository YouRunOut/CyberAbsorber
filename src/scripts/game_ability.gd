extends Resource
class_name MF_GameAbility

@export var ability_id: StringName
@export var cooldown_sec: float = 0.0
@export var cost_stamina: float = 0.0
@export var required_tags: Array[MF_GTag] = []
@export var blocked_tags: Array[MF_GTag] = []
@export var granted_effects: Array[MF_GameplayEffect] = []
