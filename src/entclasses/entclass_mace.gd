extends Node3D

@onready var hit_box: Area3D = %HitBox
@onready var label: Label3D = %Label3D
@onready var particles: GPUParticles3D = %GPUParticles3D

@onready var audio_stroke: AudioStreamPlayer3D = %Stroke
@onready var audio_smash: AudioStreamPlayer3D = %Smash

var equiped: bool
var stroke: bool
var attacking = true


func _ready():
	equiped = false
	stroke = false


func _physics_process(_delta):
	stroke = true if Main.attack else false
	hit_box.monitorable = true if stroke else false
	hit_box.monitoring = true if stroke else false


func _process(_delta):
	label.text = str(attacking)
	equiped = true if Main.equiped_weapon == "mace" else false
	visible = true if equiped else false

	if stroke:
		particles.emitting = true
		if attacking:
			attacking = false
			audio_stroke.play()


func _on_hit_box_area_entered(area):
	if area.is_in_group("Enemy"):
		audio_smash.play()


func _on_stroke_finished():
	await get_tree().create_timer(0.3).timeout
	attacking = true
