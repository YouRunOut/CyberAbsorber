extends Node3D
class_name MF_BaseWeapon

@onready var animation: AnimationPlayer = %AnimationPlayer
@onready var reload_timer: Timer = %ReloadTimer
@onready var kill_line: RayCast3D = %KillLine

@export_group("Shooting")
@export var DAMAGE: float = 25.0
@export var firing_range: float = 300.0
@export var AMMO: int = 9

@export_group("Recoil")
@export var recoil_rotation_x: Curve
@export var recoil_rotation_z: Curve
@export var recoil_position_z: Curve
@export var recoil_amp := Vector3(1, 1, 1)
@export var lerp_speed: float = 1

@export var who_take: String
@export var damage_point: Vector3
@export var flesh = false
@export var equiped: bool
@export var shoot = false
@export var can_use = false
@export var AIMING: bool

var reloading = false
var target_rot: Vector3
var target_pos: Vector3
var current_time: float


func _ready():
	target_rot.y = rotation.y
	current_time = 1
	equiped = false
	visible = false


func _physics_process(delta):
	if current_time < 1:
		current_time += delta
		position.z = lerp(position.z, target_pos.z, lerp_speed * delta)
		rotation.z = lerp(rotation.z, target_rot.z, lerp_speed * delta)
		rotation.x = lerp(rotation.x, target_rot.x, lerp_speed * delta)
		target_rot.z = recoil_rotation_z.sample(current_time) * recoil_amp.y
		target_rot.x = recoil_rotation_x.sample(current_time) * -recoil_amp.x
		target_pos.z = recoil_position_z.sample(current_time) * -recoil_amp.z


func shooting():
	if can_use and AMMO > 0 and not reloading and not shoot:
		shoot = true
		apply_recoil()
		kill_line.set_target_position(bullet_spread(firing_range))
		object_hit()
		animation.play("Shoot")
		AMMO -= 1


func reload():
	if can_use and AMMO < 9 and not reloading:
		shoot = false
		reloading = true
		reload_timer.start()
		animation.play("Reload")


func hiding():
	if equiped:
		animation.play("Hide")
		can_use = false
		shoot = false


func equiping():
	if not equiped:
		animation.play("Equip")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Shoot":
		shoot = false
	if anim_name == "Hide":
		equiped = false
		animation.set_current_animation("RESET")
	if anim_name == "Equip":
		equiped = true
		can_use = true
		shoot = false


func _on_reload_timer_timeout():
	reloading = false
	if equiped:
		AMMO = 9


func object_hit():
	var hit_object = kill_line.get_collider()
	if hit_object == null:
		return

	damage_point = kill_line.get_collision_point()
	if hit_object.is_in_group("Enemy_human") or hit_object.is_in_group("Player"):
		var battle_manager = Main.get_battle_manager()
		if battle_manager:
			battle_manager.apply_damage(hit_object, int(DAMAGE), self)
		else:
			var combatant := hit_object as MF_BaseCombatant
			if combatant:
				combatant.get_damage(int(DAMAGE))
		flesh = true
	else:
		flesh = false
		if hit_object.is_in_group("Crate"):
			var direction = (damage_point - global_transform.origin).normalized()
			hit_object.apply_impulse(Vector3(direction.x, direction.y, direction.z) * 1)


func bullet_spread(length_value) -> Vector3:
	var x: float = 0
	var y: float = -length_value
	var z: float = 0
	if AIMING:
		x = randf_range(-5, 5)
		z = randf_range(-5, 5)
	else:
		match who_take:
			"Player":
				x = randf_range(-80, 80)
				z = randf_range(-80, 80)
			"Enemy":
				x = randf_range(-100, 100)
				z = randf_range(-100, 100)
	return Vector3(x, y, z)


func apply_recoil():
	recoil_amp.y *= -1 if randf() > 0.5 else 1
	target_rot.z = recoil_rotation_z.sample(0)
	target_rot.x = recoil_rotation_x.sample(0)
	target_pos.z = recoil_position_z.sample(0)
	current_time = 0


func _on_player_shoot():
	shooting()


func _on_player_reload():
	reload()


func _on_player_hide_weapon():
	hiding()


func _on_player_equip_weapon():
	equiping()


func _on_enemy_shoot():
	shooting()


func _on_enemy_reload():
	reload()


func _on_enemy_hide_weapon():
	hiding()


func _on_enemy_equip_weapon():
	equiping()
