extends Node3D

@onready var animation: AnimationPlayer = %AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	animation.play("idle")

func _on_hitbox_area_entered(area):
	var player_health = Main.get_player_health_component()
	if area.is_in_group('player_hitbox') and player_health and player_health.current_hp < player_health.max_hp:
		Main.increase_gold()
		queue_free()
