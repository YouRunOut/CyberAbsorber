extends Node

var lvlup : bool

#var enemy_position : Vector3
var player_position : Vector3

var player_hp : int
var MaxHp = 100

var kills : int
var anima : int
var gold : int
var Exp : int
@export var ExpMax : int = 1000

var aiming_speed = 10

var runnerL = 0
var runnerR = 1
var L_first_enter = true
var R_first_enter = true
var C_first_enter = true

var char_level : int = 2
var skill_point : int

var skill_book : Dictionary

var player_dead = false

var quilt_done = false
var nearest_enemy = null

var player_damage : float
var attack : bool
var equiped_weapon : String


@export var RIFLE_DAMAGE : float = 15.0

@export var quilt_lvl = 0
@export var q_plus = 15.0 # [20.0, 25.0, 30.0]
@export var q_boost = 2
@export var q_minus = 4.0 # [5.0, 3.0, 2.0, 1.0]
@export var q_down = 4.0 # [10.0, 8.0, 5.0, 4.0, 3.0]

var can_next_lvl = true

func _ready():
	player_hp = MaxHp - 10
	
	equiped_weapon = 'pistol'
	set_skill_book()
	
@warning_ignore("unused_parameter")
func _process(delta):
	
	if player_hp > MaxHp:
		player_hp = MaxHp
	CharLevelUp()

func CharLevelUp():
	if Exp >= ExpMax:
		Exp = Exp - ExpMax
		char_level += 1
		lvlup = true
		if char_level > 2:
			skill_point += 1
	else: lvlup = false

func set_skill_book():
	skill_book = {
		'L00':  [false, preload("res://Pics/MainMenu/skill_pic/skill_L00.png"), "Энергия накапливается слегка быстрее"],
		'L01':  [false, preload("res://Pics/MainMenu/skill_pic/skill_L01.png"), "Энергия накапливается быстрее"],
		'L10':  [false, preload("res://Pics/MainMenu/skill_pic/skill_L10.png"), "Энергия накапливается значительно быстрее"],
		'L11':  [false, preload("res://Pics/MainMenu/skill_pic/skill_L11.png"), "Больше не нужно многократно нажимать [Q], достаточно зажать"],
		'L20':  [false, preload("res://Pics/MainMenu/skill_pic/skill_L20.png"), "Энергия накапливается мгновенно"],
		
		'R00':  [false, preload("res://Pics/MainMenu/skill_pic/skill_R00.png"), "Рассеивание энергии слегка замедлено"],
		'R01':  [false, preload("res://Pics/MainMenu/skill_pic/skill_R01.png"), "Рассеивание энергии замедлено"],
		'R10':  [false, preload("res://Pics/MainMenu/skill_pic/skill_R10.png"), "Рассеивание энергии значительно замедлено"],
		'R11':  [false, preload("res://Pics/MainMenu/skill_pic/skill_R11.png"), "Рассеивание энергии очень медленное"],
		'R20':  [false, preload("res://Pics/MainMenu/skill_pic/skill_R20.png"), "Рассеивание энергии отсутствует"],
		
		'C00':  [false, preload("res://Pics/MainMenu/skill_pic/skill_C00.png"), "Смерть во плоти"]
	}

func upgrade(skill_name):
	match skill_name:
		'L00': q_plus = 20.0
		'L01': q_plus = 25.0
		'L10': q_plus = 30.0
		'L11': quilt_lvl = 1
		'L20': q_boost = 3
		
		'R00': print('None upgrade ' + skill_name)
		'R01': print('None upgrade ' + skill_name)
		'R10': print('None upgrade ' + skill_name)
		'R11': print('None upgrade ' + skill_name)
		'R20': print('None upgrade ' + skill_name)
		
		'C00': print('None upgrade ' + skill_name)

func increase_anima():
	Exp += 1000
	anima += 1
	player_hp += 25

func increase_gold():
	Exp += 50
	#gold += 1
	player_hp += 10
