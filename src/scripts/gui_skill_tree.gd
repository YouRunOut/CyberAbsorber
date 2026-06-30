extends Control
@onready var exit_button: Button = %ExitButton
@onready var audio_hover: AudioStreamPlayer2D = %AudioHover
@onready var audio_pressed: AudioStreamPlayer2D = %AudioPressed

@onready var lvl_count: Label = %Count
@onready var skill_point_count: Label = %SkillPointCount

@onready var exp_progress_bar: TextureProgressBar = %ExpProgressBar
@onready var exp_count: Label = %ExpCount

@onready var soundtrack: AudioStreamPlayer = %Soundtrack
@onready var background: Control = %Background
@onready var bg_particles: GPUParticles2D = %GPUParticles2D

func _ready():
	pass

@warning_ignore("unused_parameter")
func _process(delta):
	aspect_ratio()
	
	exp_progress_bar.value = Main.Exp
	exp_count.text = str(Main.Exp)
	lvl_count.text = str(Main.char_level)
	
	if Main.skill_point == 0:
		skill_point_count.visible = false
	else:
		skill_point_count.visible = true
		var txt = 'Perks: {0}'
		skill_point_count.text = txt.format([Main.skill_point])

func sound():
	if self.visible == true:
		soundtrack.play()
	else: soundtrack.stop()

func aspect_ratio():
	bg_particles.position.x = background.size.x / 2
	bg_particles.position.y = background.size.y / 2

func _on_exit_button_pressed():
	audio_pressed.play()
	get_tree().quit()

func _on_exit_button_mouse_entered():
	audio_hover.play()
