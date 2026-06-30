extends Control

@export var hack_ui_scene: PackedScene

@onready var audio_quilt_done: AudioStreamPlayer2D = %QuiltDone
@onready var audio_death: AudioStreamPlayer = %Death
@onready var audio_pick_coin: AudioStreamPlayer2D = %PickCoin

@onready var crosshair: TextureRect = %Crosshair

@onready var hud: Control = %HUD

@onready var tree_animation: AnimationPlayer = %TreeAnimation
@onready var skill_tree: Control = %SkillTree
@export var skill_tree_open : bool

@onready var hp_bar: TextureProgressBar = %HPbar
@onready var hp_percentage: Label = %HP

@onready var anima_count: Label = %Anima
@onready var exp_progress_bar: TextureProgressBar = %HUDExpProgressBar
@onready var new_skill: Label = %NewSkillLogo

@onready var gold_ui: Control = %GoldCount
@onready var gold_count: Label = %Gold

@onready var btn_q: TextureButton = %btn_Q
@onready var btn_e: TextureButton = %btn_E

@onready var death_particles: GPUParticles2D = %GPUParticles2D

@onready var death_text: RichTextLabel = %AnimationText.get_parent().get_node("Death text")
@onready var fade_animation: AnimationPlayer = %FadeAnimatoin
@onready var text_animation: AnimationPlayer = %AnimationText
@onready var death_canvas_layer: CanvasLayer = %CanvasLayer
@onready var death_screen: Control = fade_animation.get_parent()
@onready var death_color_rect: ColorRect = %ColorRect

# Called when the node enters the scene tree for the first time.
func _ready():
	print_debug(death_color_rect.material.shader)
	hp_bar.value
	Main.player_dead = false
	death_text.visible = false
	skill_tree_open = false
	death_screen.visible = false
	death_canvas_layer.visible = false

func changescene():
	if Main.kills == 15 and Main.can_next_lvl:
		#anima_count.text = 'OK'
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://Scenes/FirstLevel.tscn")#"res://Scenes/SecondLevel.tscn"
		Main.can_next_lvl = false
	else: return

# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta):
	new_skill.visible = true if Main.skill_point > 0 else false
	
	aspect_ratio()
	changescene()
	exp_progress_bar.value = Main.Exp
	hp_bar.value = Main.player_hp
	hp_percentage.text = str(Main.player_hp)
	if Main.gold == 0:
		gold_ui.visible = false
	else:
		gold_ui.visible = true
		gold_count.text = str(Main.gold)
		
	if Main.anima == 0:
		anima_count.visible = false
	else:
		anima_count.visible = true
		anima_count.text = str(Main.anima)
	
	if not Main.player_dead:
		if Input.is_action_just_pressed("SkillTree"):
			is_open_skilltree()

	if Input.is_action_pressed("Quilt"):
		btn_q.button_pressed = true
	else:
		btn_q.button_pressed = false
	
	if Input.is_action_pressed("Energy"):
		btn_e.button_pressed = true
	else:
		btn_e.button_pressed = false

func _on_player_gathered():
	btn_q.visible = false
	audio_quilt_done.play()

func _on_player_coin_here():
	audio_pick_coin.play()

func _on_player_alive():
	fade_animation.play("defade")
	text_animation.play("death_end")
	hud.visible = true

func _on_fade_animatoin_animation_finished(anim_name):
	if anim_name == "defade":
		death_screen.visible = false

func _on_player_death():
	hud.visible = false
	audio_death.play()
	death_particles.restart()
	death_particles.emitting = true
	death_screen.visible = true
	death_canvas_layer.visible = true
	fade_animation.play("fade")
	text_animation.play("death_begin")

func is_open_skilltree():
	match skill_tree_open:
		true: # Если открыто - закрывает
			skill_tree_open = false
			hud.visible = true
			#skill_tree.visible = false
			tree_animation.play("close")
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		false: # И наоборот
			#skill_tree.dethparticls.emit
			skill_tree_open = true
			hud.visible = false
			#skill_tree.visible = true
			tree_animation.play("open")
			#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func restart():
	get_tree().change_scene_to_file("res://Scenes/FirstLevel.tscn")
	Main.player_hp = Main.MaxHp

func aspect_ratio():
	# положение партиклов смерти
	death_particles.position.x = death_screen.size.x / 2
	death_particles.position.y = death_screen.size.y / 2

func _on_tree_animation_animation_finished(anim_name):
	if anim_name == "open":
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func is_hacking_active() -> bool:
	return get_node_or_null("StreakControl") != null


func show_hacking() -> void:
	if is_hacking_active():
		return
	var scene = hack_ui_scene.instantiate()
	scene.name = "StreakControl"
	add_child(scene)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	scene.tree_exited.connect(_on_hack_finished)


func _on_hack_finished() -> void:
	if not skill_tree_open:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
