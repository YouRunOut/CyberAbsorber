extends Node

signal exp_changed(current_exp: int)
signal level_changed(current_level: int)
signal skill_points_changed(points: int)

var lvlup : bool

#var enemy_position : Vector3
var player_position : Vector3

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

var player_damage : float
var attack : bool
var equiped_weapon : String


@export var RIFLE_DAMAGE : float = 15.0

var can_next_lvl = true

var game_manager
var gui_manager
var ai_manager
var scene_flow_manager
var battle_manager
var entity_pool_manager
var save_state_registry
var save_state_serializer
var save_load_manager
var ability_runtime


func _init_managers() -> void:
	game_manager = MF_GameManager.new()
	gui_manager = MF_GuiManager.new()
	ai_manager = MF_AiManager.new()
	scene_flow_manager = MF_SceneFlowManager.new()
	battle_manager = MF_BattleManager.new()
	entity_pool_manager = MF_EntityPoolManager.new()
	save_state_registry = MF_SaveStateRegistry.new()
	save_state_serializer = MF_SaveStateSerializer.new()
	save_load_manager = MF_SaveLoadManager.new()
	ability_runtime = Node.new()
	ability_runtime.name = "AbilitySystemRuntime"

	add_child(game_manager)
	add_child(gui_manager)
	add_child(ai_manager)
	add_child(scene_flow_manager)
	add_child(battle_manager)
	add_child(entity_pool_manager)
	add_child(save_state_registry)
	add_child(save_state_serializer)
	add_child(save_load_manager)
	add_child(ability_runtime)
	save_load_manager.configure(save_state_registry, save_state_serializer)

func _ready():
	_init_managers()
	equiped_weapon = 'pistol'
	set_skill_book()
	emit_signal("exp_changed", Exp)
	emit_signal("skill_points_changed", skill_point)
	
@warning_ignore("unused_parameter")
func _process(delta):
	CharLevelUp()

func CharLevelUp():
	if Exp >= ExpMax:
		Exp = Exp - ExpMax
		char_level += 1
		lvlup = true
		emit_signal("level_changed", char_level)
		if char_level > 2:
			skill_point += 1
			emit_signal("skill_points_changed", skill_point)
	else: lvlup = false

func set_skill_book():
	skill_book = {
		'L00':  [false, preload("res://assets/pics/main_menu/skill_pic/skill_L00.png"), "Энергия накапливается слегка быстрее"],
		'L01':  [false, preload("res://assets/pics/main_menu/skill_pic/skill_L01.png"), "Энергия накапливается быстрее"],
		'L10':  [false, preload("res://assets/pics/main_menu/skill_pic/skill_L10.png"), "Энергия накапливается значительно быстрее"],
		'L11':  [false, preload("res://assets/pics/main_menu/skill_pic/skill_L11.png"), "Больше не нужно многократно нажимать [Q], достаточно зажать"],
		'L20':  [false, preload("res://assets/pics/main_menu/skill_pic/skill_L20.png"), "Энергия накапливается мгновенно"],
		
		'R00':  [false, preload("res://assets/pics/main_menu/skill_pic/skill_R00.png"), "Рассеивание энергии слегка замедлено"],
		'R01':  [false, preload("res://assets/pics/main_menu/skill_pic/skill_R01.png"), "Рассеивание энергии замедлено"],
		'R10':  [false, preload("res://assets/pics/main_menu/skill_pic/skill_R10.png"), "Рассеивание энергии значительно замедлено"],
		'R11':  [false, preload("res://assets/pics/main_menu/skill_pic/skill_R11.png"), "Рассеивание энергии очень медленное"],
		'R20':  [false, preload("res://assets/pics/main_menu/skill_pic/skill_R20.png"), "Рассеивание энергии отсутствует"],
		
		'C00':  [false, preload("res://assets/pics/main_menu/skill_pic/skill_C00.png"), "Смерть во плоти"]
	}

func upgrade(skill_name):
	var attributes := get_player_attributes()
	if attributes == null:
		return
	match skill_name:
		'L00': attributes.quilt_charge_gain_tap = 20.0
		'L01': attributes.quilt_charge_gain_tap = 25.0
		'L10': attributes.quilt_charge_gain_tap = 30.0
		'L11': attributes.quilt_hold_mode_unlocked = true
		'L20': attributes.quilt_charge_gain_hold_per_sec = 3.0
		
		'R00': print('None upgrade ' + skill_name)
		'R01': print('None upgrade ' + skill_name)
		'R10': print('None upgrade ' + skill_name)
		'R11': print('None upgrade ' + skill_name)
		'R20': print('None upgrade ' + skill_name)
		
		'C00': print('None upgrade ' + skill_name)

func increase_anima():
	Exp += 1000
	anima += 1
	emit_signal("exp_changed", Exp)

func increase_gold():
	Exp += 50
	#gold += 1
	emit_signal("exp_changed", Exp)


func get_scene_flow_manager():
	return scene_flow_manager


func get_gui_manager():
	return gui_manager


func get_ai_manager():
	return ai_manager


func get_battle_manager():
	return battle_manager


func get_entity_pool_manager():
	return entity_pool_manager


func get_save_load_manager():
	return save_load_manager


func get_player_node() -> Node:
	var players = get_tree().get_nodes_in_group("Player")
	if players.is_empty():
		return null
	return players[0]


func get_player_health_component() -> MF_HealthComponent:
	var player = get_player_node()
	if player == null:
		return null
	return player.get_node_or_null("MF_HealthComponent")


func get_player_ability_component() -> MF_AbilitySystemComponent:
	var player = get_player_node()
	if player == null:
		return null
	return player.get_node_or_null("MF_AbilitySystemComponent")


func get_player_attributes() -> MF_AttributeSet:
	var ability = get_player_ability_component()
	if ability == null:
		return null
	return ability.attributes


func get_player_hp() -> int:
	var health = get_player_health_component()
	if health:
		return health.current_hp
	return 0


func get_player_max_hp() -> int:
	var health = get_player_health_component()
	if health:
		return health.max_hp
	return 100
