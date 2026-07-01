extends Resource
class_name GameplayEffect

enum EffectMode {
	INSTANT,
	DURATION,
	INFINITE
}

@export var effect_mode: EffectMode = EffectMode.INSTANT
@export var duration_sec: float = 0.0
@export var stack_count: int = 1
@export var health_delta: float = 0.0
@export var damage_delta: float = 0.0
@export var speed_multiplier: float = 1.0
@export var tags: Array[GTag] = []
