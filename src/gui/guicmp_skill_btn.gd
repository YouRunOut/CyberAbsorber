extends TextureButton

@export var active_texture: Texture2D

@onready var audio_hover: AudioStreamPlayer2D = %AudioHover
@onready var audio_upgrade: AudioStreamPlayer2D = %AudioUpgrade
@onready var anim_note: AnimationPlayer = %AnimNote
@onready var particles: GPUParticles2D = %GPUParticles2D

@onready var lbtn_name: RichTextLabel = %BtnName
@onready var rbtn_name: RichTextLabel = %BtnName2
@onready var cbtn_name: RichTextLabel = %BtnName3

@onready var skill_pic: Sprite2D = %SkillPic
@onready var hover_skill_pic: Sprite2D = %HoverSkillPic
@onready var note: Control = %Note
@onready var writeup: Label = %writeup

var txt = '[{0}]'
var NAME : String
var skill_note : Array # [is_unlocked, icon_texture, description]
var side : String
var skill_list = ['L00', 'R00', 'L01', 'R01', 'L10', 'R10', 'L11', 'R11', 'L20', 'R20', 'C00']
var upgrade_applied := false

func _ready():
	self.disabled = true
  # NAME == (side(R,L,C), path(0,1,2), num(0,1))
	NAME = str(self).left(3) # str(self).substr(0,3)
	skill_note = Main.skill_book[NAME]
	if skill_note[1] == null:
		skill_note[1] = texture_normal
	skill_pic.set_texture(skill_note[1]) # второй объект
	writeup.text = skill_note[2]
	side = NAME[0]
	upgrade_applied = bool(skill_note[0])
	#skill_list = Main.skill_book.keys()
	
@warning_ignore("unused_parameter")
func _process(delta):
	if self.disabled == true:
		particles.visible = false
	else: particles.visible = true
	
	if skill_note[0]:
		self.set_texture_disabled(active_texture)
	skill_availability()

func skill_availability():
	if NAME == 'L00' or NAME == 'R00': # Первый скил?	
		# да, первый
		if skill_note[0]:# Активный?
			if side == 'L' and Main.L_first_enter:# левая ветка
				if not upgrade_applied:
					Main.upgrade(NAME)
					upgrade_applied = true
				Main.runnerL += 2
				Main.L_first_enter = false
			elif side == 'R' and Main.R_first_enter: # правая ветка
				if not upgrade_applied:
					Main.upgrade(NAME)
					upgrade_applied = true
				Main.runnerR += 2
				Main.R_first_enter = false
			else: self.disabled = true
		else: # нет, не активный
			self.disabled = false
			vision()
	else: # нет, не первый
		if side == 'L':
				if Main.runnerL != 0 and Main.runnerL <= 8:
					if NAME == skill_list[Main.runnerL]: # равен текущему доступу в списке?
						# да, равен
						if skill_note[0]: # активен?
							# да, активен
							if not upgrade_applied:
								Main.upgrade(NAME)
								upgrade_applied = true
							Main.runnerL += 2
							self.disabled = true
						else: # нет, не активен
							self.disabled = false
							vision()
					else: self.disabled = true
		elif side == 'R':
				if Main.runnerR != 1 and Main.runnerR <= 9:
					if NAME == skill_list[Main.runnerR]: # равен текущему доступу в списке?
						# да, равен
						if skill_note[0]: # активен?
							# да, активен
							if not upgrade_applied:
								Main.upgrade(NAME)
								upgrade_applied = true
							Main.runnerR += 2
							self.disabled = true
						else: # нет, не активен
							self.disabled = false
							vision()
					else: self.disabled = true
		else: # side == 'C'
			if NAME == 'C00':
				if Main.runnerL == 10 and Main.runnerR == 11:
					if skill_note[0]: # активен?
						# да, активен
						if Main.C_first_enter:
							if not upgrade_applied:
								Main.upgrade(NAME)
								upgrade_applied = true
							self.disabled = true
							Main.C_first_enter = false
					else: # нет, не активен
						self.disabled = false
						vision()
				else: self.disabled = true
	if Main.skill_point == 0:
		self.disabled = true

func _on_pressed():
	Main.skill_point -= 1
	Main.skill_book[NAME][0] = true
	Main.upgrade(NAME)
	upgrade_applied = true
	audio_upgrade.play()
	self.disabled = true

func _on_mouse_entered():
	anim_note.play("visible")
	hover_skill_pic.set_texture(skill_note[1])
	if not self.disabled:
		audio_hover.play()

func _on_mouse_exited():
	anim_note.play("unvisible")

func vision():
	if side == 'L':
		lbtn_name.visible = true
		lbtn_name.text = txt.format([NAME])
	elif side == 'R':
		rbtn_name.visible = true
		rbtn_name.text = txt.format([NAME])
	else:
		cbtn_name.visible = true
		cbtn_name.text = txt.format([NAME])


func _on_button_up():
	pass # Replace with function body.
