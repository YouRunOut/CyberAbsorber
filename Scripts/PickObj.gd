extends Node3D

@onready var animation: AnimationPlayer = %AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	animation.play("idle")

func _on_hitbox_area_entered(area):
	if area.is_in_group('player_hitbox') and Main.player_hp != Main.MaxHp:
		Main.increase_gold()
		queue_free()
