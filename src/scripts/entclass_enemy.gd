extends BaseCombatant

var CombatMode: bool

@onready var audio_hurt: AudioStreamPlayer3D = %Hurt
@onready var audio_fist: AudioStreamPlayer3D = %Fist

@onready var hp_label: Label3D = %S
@onready var attack_zone: Area3D = %AttackZone

@onready var search_cover: Area3D = %SearchCover
@onready var agr_area: Area3D = %AgrArea
@onready var agr_timer: Timer = %AgrTimer
@onready var view_line: RayCast3D = %ViewLine

var Nearest_cover = null
var CoverPosition: Vector3
var CoverType: int

@onready var anim: AnimationPlayer = %AnimationPlayer
@onready var hit_box: Area3D = %HitBox
@onready var visuals: Node3D = %visuals
@onready var near_quilt: Sprite3D = %NearQuilt
@onready var agent: NavigationAgent3D = %NavigationAgent3D
@onready var blood: GPUParticles3D = %GPUParticles3D

@onready var pistol = %Pistol

@export var flesh_hit_scene: PackedScene
@export var material_hit_scene: PackedScene
var hit_point

var fsm_module: Node
var perception_module: Node
var cover_module: Node
var ability_system_component: Node
var enemy_health_component: HealthComponent

var delay = false

signal shoot
signal reload
signal equip_weapon
signal hide_weapon

@export var State: int = IDLE
enum {
	STUN,
	IDLE,
	PATROL,
	ALERT,
	CHASE,
	ATTACK,
	TAKE_COVER,
	COVER
}
var last_State: int
var stun_time: float

var alerted: bool = false
var alarm_object

var hiting = false
var player

var SPEED = WALK
const WALK = 1.5
const SPRINT = 3.0

var direction = Vector3()
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func Death():
	Main.Exp += 100
	Main.kills += 1
	Main.get_ai_manager().unregister_enemy(self)
	Main.get_battle_manager().notify_death(self)
	queue_free()


func _ready():
	hp = max_hp
	pistol.who_take = "Enemy"
	CombatMode = false
	fsm_module = FsmModule.new()
	perception_module = PerceptionModule.new()
	cover_module = CoverModule.new()
	add_child(fsm_module)
	add_child(perception_module)
	add_child(cover_module)
	ability_system_component = AbilitySystemComponent.new()
	ability_system_component.attributes = AttributeSet.new()
	add_child(ability_system_component)
	enemy_health_component = HealthComponent.new()
	enemy_health_component.name = "HealthComponent"
	enemy_health_component.max_hp = max_hp
	enemy_health_component.start_hp = max_hp
	enemy_health_component.ability_component = ability_system_component
	add_child(enemy_health_component)
	health_component = enemy_health_component
	hp = enemy_health_component.current_hp
	Main.get_ai_manager().register_enemy(self)


func _process(_delta):
	hp_label.text = str(State)
	if hp <= 0:
		Death()


func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	weapon_action()
	nearest_from_player()

	match State:
		STUN: when_stun()
		IDLE: when_idle()
		PATROL: when_patrol()
		ALERT: when_alert()
		CHASE: when_chase()
		ATTACK: when_attack()
		TAKE_COVER: find_cover()
		COVER: when_cover(delta)
	fsm_module.set_state(StringName(str(State)))

	move_and_slide()


func get_damage(damage: int = 0) -> void:
	audio_hurt.play()
	take_damage(damage)

	if not CombatMode:
		CombatMode = true
		alerted = true
		State = ALERT

	if State != COVER and hp <= 50 and State != ALERT:
		State = TAKE_COVER

	if State != STUN:
		last_State = State
	State = STUN


func body_detected(area):
	for body in area.get_overlapping_bodies():
		if body.is_in_group("Player"):
			alarm_object = body
			player = body
			perception_module.set_target(body)
			return true
	return false


func is_see_player():
	var collider = view_line.get_collider()
	if collider and collider.is_in_group("Player"):
		return true
	return false


func find_and_move_to(position_point: Vector3):
	anim.play("idle")
	agent.target_position = position_point
	look_at(position_point, Vector3.UP)
	direction = (agent.get_next_path_position() - global_position).normalized()
	velocity = direction * SPEED


func stop():
	velocity = Vector3.ZERO
	agent.target_position = Vector3.ZERO


func when_stun():
	stop()
	await get_tree().create_timer(stun_time).timeout
	State = last_State


func when_idle():
	SPEED = WALK
	if not body_detected(agr_area):
		stop()
		if pistol.equiped:
			emit_signal("hide_weapon")
		if is_on_floor():
			anim.play("idle")
	else:
		alerted = true
		State = ALERT


func when_patrol():
	SPEED = WALK
	if not body_detected(agr_area):
		if pistol.equiped:
			emit_signal("hide_weapon")
		if is_on_floor():
			anim.play("idle")
	else:
		alerted = true
		State = ALERT


func when_alert():
	if alerted:
		agr_timer.start()
		alerted = false
	else:
		if not pistol.equiped:
			anim.play("BattlePose")
			emit_signal("equip_weapon")
		else:
			if not alarm_object:
				look_at(Main.player_position)
			else:
				look_at(alarm_object.position)


func when_chase():
	if body_detected(attack_zone):
		SPEED = WALK
		State = ATTACK
	else:
		SPEED = SPRINT
		if not alarm_object:
			find_and_move_to(Main.player_position)
		else:
			find_and_move_to(alarm_object.position)


func when_attack():
	SPEED = WALK
	anim.play("BattlePose")

	if not pistol.equiped:
		emit_signal("equip_weapon")
	else:
		if not Main.player_dead:
			if not alarm_object:
				look_at(Main.player_position)
			else:
				look_at(alarm_object.position)

			if is_see_player():
				if pistol.AMMO != 0:
					if not delay:
						stop()
						delay = true
						var rand_delay: float = randf_range(0.8, 1.2)
						await get_tree().create_timer(rand_delay).timeout
						emit_signal("shoot")
						delay = false
				else:
					emit_signal("reload")
			else:
				State = CHASE


func find_cover():
	nearest_cover()
	if Nearest_cover != null:
		if global_position != CoverPosition:
			find_and_move_to(CoverPosition)
		else:
			State = COVER
	else:
		State = ATTACK


func when_cover(delta):
	match CoverType:
		2: anim.play("idle")
		1: anim.play("Crouch")
	if Nearest_cover.get_parent().PlaceAvailable:
		stop()
		global_position = lerp(global_position, CoverPosition, delta * 3)
	else:
		State = TAKE_COVER


func nearest_from_player():
	var player_node = Main.get_player_node()
	if player_node and player_node.is_in_group("Player") and player_node.is_quilt_target(self) and hp <= 50:
		stun_time = 1.5
		State = STUN
		near_quilt.visible = true
		if player_node.try_consume_quilt_on_enemy(self):
			blood.emitting = true
			hp = 0
			Main.increase_anima()
	else:
		stun_time = 0.4
		near_quilt.visible = false


func nearest_cover():
	Nearest_cover = null
	var Covers = search_cover.get_overlapping_areas()
	if not Covers:
		return

	Nearest_cover = Covers[0]
	for cover in Covers:
		if str(cover).left(6) != "Search":
			if cover.global_position.distance_to(global_position) < Nearest_cover.global_position.distance_to(global_position):
				Nearest_cover = cover
				CoverPosition = cover.global_position
		else:
			return


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "attack":
		hiting = false
		if Main.player_dead:
			State = IDLE


func _on_agr_timer_timeout():
	if is_see_player():
		CombatMode = true
		emit_signal("equip_weapon")
		State = CHASE
	else:
		State = IDLE


func hit_player():
	if not hiting:
		hiting = true
		if body_detected(attack_zone):
			if not Main.player_dead:
				player.get_damage(10)
				audio_fist.play()


func spawn_hit_point(hit_cords):
	var hit_point_inst = hit_point.instantiate()
	hit_point_inst.global_position = hit_cords
	get_parent().add_child(hit_point_inst)


func weapon_action():
	if pistol.damage_point != Vector3.ZERO:
		if pistol.flesh:
			hit_point = flesh_hit_scene
		else:
			hit_point = material_hit_scene
		spawn_hit_point(pistol.damage_point)
		pistol.damage_point = Vector3.ZERO


func in_cover(pos, type):
	State = COVER
	CoverPosition = pos
	CoverType = type
	cover_module.set_cover(pos, type)
