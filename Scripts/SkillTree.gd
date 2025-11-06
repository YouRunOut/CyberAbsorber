extends Control
@onready var exit_button = $MarginContainer/Body/ExitButton
@onready var audio_hover = $MarginContainer/Body/ExitButton/AudioHover
@onready var audio_pressed = $MarginContainer/Body/ExitButton/AudioPressed

@onready var lvl_count = $MarginContainer/Body/Header/LVL/Count
@onready var skill_point_count = $MarginContainer/Body/SkillPointCount

@onready var exp_progress_bar = $MarginContainer/Body/ExpProgress/ExpProgressBar
@onready var exp_count = $MarginContainer/Body/ExpProgress/ExpProgressBar/ExpCount

@onready var soundtrack = $Soundtrack
@onready var background = $Background
@onready var bg_particles = $Background/GPUParticles2D

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
