extends BaseCombatant

#region All imports
@export var flesh_hit_scene: PackedScene
@export var material_hit_scene: PackedScene

@onready var hp_timer: Timer = %HpTimer

@onready var animation: AnimationPlayer = %AnimationPlayer
@onready var hand_anim: AnimationPlayer = %HandAnim
@onready var time_to_take: Timer = %TimeToTake
var taking = false
@onready var ray_push: RayCast3D = %RayPush

@onready var audio: AudioStreamPlayer = %LVLUP
@onready var audio_foot_landing: AudioStreamPlayer3D = %AudioFootLanding

@onready var flash_light: Node3D = %FlashLight

@onready var right_hand: Node3D = %RightHand

@onready var pistol = %Pistol

var hit_point

@onready var gui: Control = %GUI

@onready var qtimer: Timer = %qTimer
@onready var q3timer: Timer = %q3Timer

@onready var quilt_area: Area3D = %Quilt_area
@onready var visuals: Node3D = %Visuals

@onready var nek: Node3D = %nek
@onready var head: Node3D = %head
@onready var eyes: Node3D = %eyes
@onready var camera: Camera3D = %Camera3D



@onready var standing_collision: CollisionShape3D = %Standing_collision
@onready var HB_stand: CollisionShape3D = %Stand
@onready var crouching_collision: CollisionShape3D = %Crouching_collision
@onready var HB_crouch: CollisionShape3D = %Crouch
@onready var hit_box: Area3D = %HitBox

@onready var slide_timer: Timer = %SlideTimer

@onready var above_check: RayCast3D = %AboveCheck

@onready var agent: NavigationAgent3D = %NavigationAgent3D

var movement_module: Node
var camera_module: Node
var quilt_module: Node
var ability_system_component: Node
var player_health_component: HealthComponent
var ga_quilt: GA_Quilt
var ga_on_kill_heal: GA_OnKillHeal
#endregion

#region All signals
signal gathered
signal coin_here
signal death
signal alive

signal shoot
signal reload
signal equip_weapon
signal hide_weapon

#endregion

#region All variables

#states
var WEAPON_EQUIPED = false

var WALKING = false
var SPRINTING = false
var CROUCHING = false
var LOOKING = false
var SLIDING = false

var SPEED : float
@export_group("Move speed")
@export var SLOW:float
@export var WALK:float
@export var SPRINT:float
@export var JUMP_VELOCITY:float

var direction = Vector3.ZERO
var last_velocity = Vector3.ZERO

var slide_vector = Vector2.ZERO
const  SLIDE_SPEED = 10.0

const crouch_depth = 1.0
var player_height = 1.8


var reboot_quilt = false

@export var lerp_speed: float = 2.3
@export var air_lerp_speed: float = 0.8
@export var motion_lerp_speed: float = 3.0

# head bobbing

@export var sprint_bobbing_speed: float = 12.0
@export var walk_bobbing_speed: float = 9.0
@export var crouch_bobbing_speed: float = 6.0

@export var sprint_bobbing_intensity: float = 0.25
@export var walk_bobbing_intensity: float = 0.1#0.08
@export var crouch_bobbing_intensity: float = 0.1

var bobbing_intensity = 0.0
var bobbing_vector = Vector2.ZERO
var bobbing_index = 0.0

const free_looking_tilt_amount = 0.3 

@export var sens_horizontal = 0.1
@export var sens_vertical = 0.1
@export var sens_aiming = 1.0

@export var pistol_hip_shooting : Vector3 = Vector3(0.277, -0.393, 0) # стрельба от бедра
@export var pistol_aiming_shooting : Vector3 = Vector3(0, -0.313, 0) # прицельная стрельба

var mouse_input : Vector2
var def_weapon_holder_pos : Vector3
@export var weapon_holder : Node3D
@export var weapon_sway_amount : float = 5
@export var weapon_rotation_amount : float = 1

@export var cam_rotation_amount : float = 1

var time_lapse = false
var slow_time : float = 0.1

# Footstep vars
var step_freq : float = 5.0
var step_amp : float = 2.5
var t_step : float = 0.0
var can_play : bool = true
signal step

var bob_amount: float = 0.05
var bob_freq: float = 0.005

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
#endregion

func _ready():
	hp = max_hp
	step_amp = WALK
	pistol.who_take = "Player"
	WEAPON_EQUIPED = false
	SPEED = WALK
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	def_weapon_holder_pos = weapon_holder.position
	movement_module = MovementModule.new()
	camera_module = CameraModule.new()
	quilt_module = QuiltModule.new()
	add_child(movement_module)
	add_child(camera_module)
	add_child(quilt_module)
	ability_system_component = AbilitySystemComponent.new()
	ability_system_component.attributes = AttributeSet.new()
	add_child(ability_system_component)
	ga_quilt = GA_Quilt.new()
	ga_on_kill_heal = GA_OnKillHeal.new()
	ability_system_component.add_owned_ability(ga_quilt)
	ability_system_component.add_owned_ability(ga_on_kill_heal)
	player_health_component = HealthComponent.new()
	player_health_component.name = "HealthComponent"
	player_health_component.max_hp = max_hp
	player_health_component.start_hp = max_hp
	player_health_component.ability_component = ability_system_component
	add_child(player_health_component)
	health_component = player_health_component
	hp = player_health_component.current_hp
	quilt_module.configure(ability_system_component, quilt_area)
	Main.get_battle_manager().combatant_died.connect(_on_battle_combatant_died)
	movement_module.movement_tick.connect(_on_movement_module_tick)
	camera_module.camera_tick.connect(_on_camera_module_tick)
	quilt_module.quilt_tick.connect(_on_quilt_module_tick)

@warning_ignore("unused_parameter")
func _process(delta):
	
	if Main.lvlup:
		audio.play()
		
	if Input.is_action_just_pressed("TIME"):
		time_speed()

func _physics_process(delta):
	Main.player_position = eyes.global_position - nek.position
	
	if SPRINTING:
		t_step += (delta * velocity.length() * float(is_on_floor())/1.4)
	else:
		t_step += delta * velocity.length() * float(is_on_floor())
	steps(t_step)
	
	if not Main.player_dead:
		if !gui.is_skill_tree_open() and not gui.is_hacking_active():
			#pushing()
			camera_module.tick(delta)
			movement_module.tick(delta)
			quilt_module.tick()
			weapon_actions(delta)
			weapon_sway(delta)


func _on_movement_module_tick(delta: float) -> void:
	movements(delta)


func _on_camera_module_tick(delta: float) -> void:
	aiming_state(delta)


func _on_quilt_module_tick() -> void:
	Quilt()

func _input(event):
	if !gui.is_skill_tree_open() and not gui.is_hacking_active():
		_is_on_action_buttons()
		
		# camera motion
		if event is InputEventMouseMotion:
			mouse_input = event.relative
			if LOOKING:
				nek.rotate_y(deg_to_rad(-event.relative.x * sens_horizontal) * sens_aiming)
				nek.rotation.y = clamp(nek.rotation.y, deg_to_rad(-120), deg_to_rad(120))
				head.rotate_x(deg_to_rad(-event.relative.y * sens_vertical) * sens_aiming)
				head.rotation.x = clamp(head.rotation.x, -1.25, 1.5)
			else:
				rotate_y(deg_to_rad(-event.relative.x * sens_horizontal) * sens_aiming)
				head.rotate_x(deg_to_rad(-event.relative.y * sens_vertical) * sens_aiming)
				head.rotation.x = clamp(head.rotation.x, -1.25, 1.5)


func time_speed():
	if not time_lapse:
		time_lapse = true
		var tween1 = get_tree().create_tween()
		tween1.tween_property(Engine, "time_scale", slow_time, 1.0)
		var tween2 = get_tree().create_tween()
		tween2.tween_property(AudioServer, "playback_speed_scale", slow_time, 1.0)
	else:
		time_lapse = false
		var tween1 = get_tree().create_tween()
		tween1.tween_property(Engine, "time_scale", 1.0, 0.8)
		var tween2 = get_tree().create_tween()
		tween2.tween_property(AudioServer, "playback_speed_scale", 1.0, 0.8)


func steps(time):
	var pos = Vector3.ZERO
	pos.y = sin(time * step_freq) * step_amp
	pos.x = cos(time * step_freq / 2) * step_amp
	
	var low_pos = step_amp * 0.005
	if pos.y > -low_pos:
		can_play = true
	
	if pos.y < -low_pos and can_play:
		can_play = false
		emit_signal("step")
	return pos

func cam_tilt(input_x, delta):
	camera.rotation.z = lerp(camera.rotation.z, -input_x * cam_rotation_amount, 3 * delta)

func weapon_tilt(input_x, delta):
	if weapon_holder:
		weapon_holder.rotation.z = lerp(weapon_holder.rotation.z, -input_x * weapon_rotation_amount, 10 * delta)

func weapon_sway(delta):
	mouse_input = lerp(mouse_input, Vector2.ZERO, 125*delta)
	weapon_holder.rotation.x = lerp(weapon_holder.rotation.x, mouse_input.y * weapon_rotation_amount, 10*delta)
	weapon_holder.rotation.y = lerp(weapon_holder.rotation.y, mouse_input.x * weapon_rotation_amount, 10*delta)

func weapon_bob(vel: float, delta):
	if weapon_holder:
		if vel > 0:
			#var bob_amount: float = 0.05
			#var bob_freq: float = 0.005
			weapon_holder.position.x = lerp(weapon_holder.position.x, def_weapon_holder_pos.x + sin(Time.get_ticks_msec() * bob_freq) * bob_amount, 10*delta)
			weapon_holder.position.y = lerp(weapon_holder.position.y, def_weapon_holder_pos.y + sin(Time.get_ticks_msec() * bob_freq * 0.5) * bob_amount, 10*delta)
		else:
			weapon_holder.position.x = lerp(weapon_holder.position.x, def_weapon_holder_pos.x, 10*delta)
			weapon_holder.position.y = lerp(weapon_holder.position.y, def_weapon_holder_pos.y, 10*delta)


func Reborn():
	if Main.player_dead:
		emit_signal("alive")
		if player_health_component:
			player_health_component.reset_health()
			hp = player_health_component.current_hp
		Main.player_dead = false
		visuals.visible = true

func Death():
	emit_signal("death")
	Main.player_dead = true
	visuals.visible = false


#region skill_QUILT
func Quilt_level():
	if ability_system_component == null or ability_system_component.attributes == null:
		return
	if ability_system_component.attributes.quilt_hold_mode_unlocked:
		if Input.is_action_pressed("Quilt"):
			q3timer.start()
			quilt_module.tick_charge(true)
		else:
			q3timer.stop()
	else:
		if Input.is_action_just_pressed("Quilt"):
			quilt_module.tick_charge(true)

func Quilt():
	QNearestEnemy()
	gui.set_quilt_progress(quilt_module.charge_value)
	if quilt_module.nearest_enemy and !reboot_quilt:
		gui.set_quilt_button_visible(true)
		if not Main.player_dead:
			Quilt_level()
	else:
		gui.set_quilt_button_visible(false)
	if quilt_module.quilt_ready_pending and !reboot_quilt:
		emit_signal("gathered")
		reboot_quilt = true
		var cooldown_sec: float = float(ability_system_component.attributes.quilt_cooldown_sec) if ability_system_component and ability_system_component.attributes else 4.0
		await get_tree().create_timer(cooldown_sec).timeout
		reboot_quilt = false
		gui.set_quilt_button_visible(true)

func Quilt_degrease():
	quilt_module.tick_charge(false)

func _on_q_timer_timeout():
	Quilt_degrease()

func QNearestEnemy():
	quilt_module.update_target(global_position)

#endregion

func _is_on_action_buttons():
	'''
	if taking: 
		if time_to_take.time_left != 1.2: time_to_take.start()
	else: time_to_take.stop()
	# Action
	if Input.is_action_pressed("Action"):
		taking = true
		print(time_to_take.time_left)'''
	if Input.is_action_just_pressed("Action"):
		for area in hit_box.get_overlapping_areas():
			if area.is_in_group("Hacking"):
				gui.show_hacking()
				return
		if not hand_anim.is_playing():
			hand_anim.play("take")
			#ray_push.enabled = true
	
		
	
	# Flashlight
	if Input.is_action_just_released("FlashLight"):
		if flash_light.visible: flash_light.visible = false
		else: flash_light.visible = true
	
	# Exit
	if Input.is_action_just_pressed("Escape"):
		get_tree().quit()
	
	# Умереть\Возродиться
	if Input.is_action_just_released("Reborn"):
		# Legacy test scene was removed during restructure.
		Reborn()
	
	# Change scene
	if Input.is_action_just_released("1"):
		get_tree().change_scene_to_file("res://assets/scenes/locations/FirstLevel.tscn")
	if Input.is_action_just_released("2"):
		get_tree().change_scene_to_file("res://assets/scenes/locations/SecondLevel.tscn")

func _on_hit_box_area_entered(area):
	if not Main.player_dead:
		
		if area.is_in_group('coin') and player_health_component and player_health_component.current_hp < player_health_component.max_hp:
			emit_signal("coin_here")
		
		if area.is_in_group('saw'): # collision layer, mask = 1
			get_damage(randi_range(80, 100))

func _on_slide_timer_timeout():
	LOOKING = false
	SLIDING = false

func weapon_actions(delta):
	if gui.is_hacking_active():
		return
	if Input.is_action_just_pressed("Attack1"):
		for area in hit_box.get_overlapping_areas():
			if area.is_in_group("Hacking"):
				gui.show_hacking()
				return
		emit_signal("shoot")
		
		# отдача
		if pistol.shoot:
			head.rotation.x += 0.05
			nek.rotation.y -= 0.02
		
		# в зависимости по какому материалу попал - подгружает нужную сцену партиклов
		if pistol.damage_point != Vector3(0,0,0):
			if pistol.flesh:
				hit_point = flesh_hit_scene
			else:
				hit_point = material_hit_scene
			# спавнит точку попадания по координатам
			spawn_hit_point(pistol.damage_point)
			pistol.damage_point = Vector3(0,0,0)
	
	if Input.is_action_just_pressed("Reload"):
		emit_signal("reload")
		
	if Input.is_action_just_pressed("Weapon1"):
		if pistol.equiped:
			emit_signal("hide_weapon")
		else:
			emit_signal("equip_weapon")

func get_damage(damage: int = 0) -> void:
	take_damage(damage)
	if hp <= 0:
		if not Main.player_dead:
			Death()
			return
	gui.play_damage_feedback()


func get_current_hp() -> int:
	return player_health_component.current_hp if player_health_component else hp


func get_max_hp() -> int:
	return player_health_component.max_hp if player_health_component else max_hp


func try_consume_quilt_on_enemy(enemy: Node3D) -> bool:
	return quilt_module.consume_ready_for_target(enemy)


func is_quilt_target(enemy: Node3D) -> bool:
	return quilt_module.nearest_enemy == enemy


func _on_battle_combatant_died(combatant: Node) -> void:
	if combatant and combatant.is_in_group("Enemy_human"):
		ability_system_component.activate_ability_by_id(StringName("GA_OnKillHeal"))
	
	

func _on_hp_timer_timeout():
	pass#get_damage(1)

func movements(delta):
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	
	# Свободный взгляд
	if Input.is_action_pressed("Look") or SLIDING: 
		LOOKING = true
		if SLIDING:
			eyes.rotation.z = lerp(eyes.rotation.z, -deg_to_rad(6.0), delta * motion_lerp_speed)
		else:
			eyes.rotation.z = -deg_to_rad(nek.rotation.y * free_looking_tilt_amount)
	else:
		LOOKING = false
		nek.rotation.y = lerp(nek.rotation.y, 0.0, delta * motion_lerp_speed)
		eyes.rotation.z = lerp(eyes.rotation.z, 0.0, delta * motion_lerp_speed)
	
	# Вычисление интенсивности покачиваний головы, в зависимости от состояния
	if SPRINTING:
		bobbing_intensity = sprint_bobbing_intensity
		bobbing_index += sprint_bobbing_speed * delta
	elif WALKING:
		bobbing_intensity = walk_bobbing_intensity
		bobbing_index += walk_bobbing_speed * delta
	elif CROUCHING:
		bobbing_intensity = crouch_bobbing_intensity
		bobbing_index += crouch_bobbing_speed * delta
	
	if is_on_floor():
		direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)
		
		# Handle Jump.
		if Input.is_action_just_pressed("ui_accept"):
			animation.play("jump")
			SLIDING = false
			velocity.y = JUMP_VELOCITY
			
		# Initiate crouching
		if Input.is_action_pressed("Crouch") or SLIDING: # crouching
			SPEED = lerp(SPEED, SLOW, delta * lerp_speed)
			nek.position.y = lerp(nek.position.y, crouch_depth, delta * motion_lerp_speed)
			crouching_collision.disabled = false
			standing_collision.disabled = true
			HB_crouch.disabled = false
			HB_stand.disabled = true
			
			# initiate sliding
			if SPRINTING and input_dir != Vector2.ZERO and is_on_floor():
				slide_timer.start()
				SLIDING = true
				LOOKING = true
				slide_vector = input_dir
			
			WALKING = false
			SPRINTING = false
			CROUCHING = true
		
		elif !above_check.is_colliding(): # standing
			crouching_collision.disabled = true
			standing_collision.disabled = false
			HB_crouch.disabled = true
			HB_stand.disabled = false
			nek.position.y = lerp(nek.position.y, player_height, delta * motion_lerp_speed)
			
			if Input.is_action_pressed("Shift") and !Input.is_action_pressed("Backward") and not pistol.AIMING: # sprinting
				SPEED = lerp(SPEED, SPRINT, delta * lerp_speed)
				WALKING = false
				SPRINTING = true
				CROUCHING = false
			else: # walking
				SPEED = lerp(SPEED, WALK, delta * lerp_speed)
				WALKING = true
				SPRINTING = false
				CROUCHING = false
				
		# Применяется покачивание камеры, если не слайдит и двигается
		if !SLIDING and input_dir != Vector2.ZERO:
			weapon_bob(velocity.length(), delta)
			bobbing_vector.y = sin(bobbing_index)
			bobbing_vector.x = sin(bobbing_index/2)
			
			eyes.position.y = lerp(eyes.position.y, bobbing_vector.y * bobbing_intensity, delta * lerp_speed) # bobbing_intensity/2
			eyes.position.x = lerp(eyes.position.x, bobbing_vector.x * bobbing_intensity/2, delta * lerp_speed)
		else:
			eyes.position.y = lerp(eyes.position.y, 0.0, delta * motion_lerp_speed)
			eyes.position.x = lerp(eyes.position.x, 0.0, delta * motion_lerp_speed)
			
			
		# В зависимости от высоты проигрывает различную анимацию приземления и наносит урон
		if last_velocity.y < 0.0:
			#print(last_velocity.y)
			if last_velocity.y > -6:
				animation.play("light_landing")
				
			elif last_velocity.y < -6 and last_velocity.y > -10:
				get_damage(int(-last_velocity.y))
				animation.play("heavy_landing")
				
			elif last_velocity.y < -10 and last_velocity.y > -18:
				get_damage(int(-last_velocity.y*2.5))
				animation.play("heavy_landing")
				
			elif last_velocity.y < -18:
				get_damage(int(-last_velocity.y*5))
				animation.play("heavy_landing")
	else:
		if input_dir != Vector2.ZERO:
			direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * air_lerp_speed)
	
	# sliding
	if SLIDING:
		direction = (transform.basis * Vector3(slide_vector.x,0,slide_vector.y)).normalized()
		SPEED = (slide_timer.time_left + 0.1) * SLIDE_SPEED
		nek.position.y = lerp(nek.position.y, crouch_depth, delta * motion_lerp_speed)
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	last_velocity = velocity
	move_and_slide()
	
	cam_tilt((-mouse_input.x / 20), delta) # Наклон головы при повороте
	cam_tilt(input_dir.x, delta) # Наклон головы при шаге влево/вправо
	
	weapon_tilt(input_dir.x, delta)
	weapon_tilt((mouse_input.x / 20), delta)

func aiming_state(delta):
	if pistol.equiped:
		if Input.is_action_pressed('Aiming'):
			camera.fov = lerp(camera.fov, 60.0, delta * 10)
			sens_aiming = 0.5
			pistol.AIMING = true
			weapon_holder.position = lerp(weapon_holder.position, pistol_aiming_shooting, delta * 10)
			if !Input.is_action_pressed("Forward") or !Input.is_action_pressed("Backward") or !Input.is_action_pressed("Left") or !Input.is_action_pressed("Right"):
				gui.set_crosshair_visible(false)
			else: gui.set_crosshair_visible(true)
			if is_on_floor():
				SPEED = SLOW
		else:
			camera.fov = lerp(camera.fov, 75.0, delta * 10)
			sens_aiming = 1.0
			gui.set_crosshair_visible(true)
			pistol.AIMING = false
			weapon_holder.position = lerp(weapon_holder.position, pistol_hip_shooting, delta * 10)
	else:
		gui.set_crosshair_visible(false)

func spawn_hit_point(hit_cords):
	var hit_point_inst = hit_point.instantiate() #создает экземпляр
	hit_point_inst.global_position = hit_cords # назначает координаты (точку в пространстве)
	get_parent().add_child(hit_point_inst) # добавляет на сцену мира

func _on_time_to_take_timeout():
	hand_anim.play("take")

func _on_hand_anim_animation_finished(anim_name):
	if anim_name == "push":
		ray_push.enabled = false

func pushing():
	if str(ray_push.get_collider()) != "<Object#null>": # КОСТЫЛЬ, если без него рэйкастить в пустоту - выдает ошибку
		
		var push_object = ray_push.get_collider()
		var push_point = ray_push.get_collision_point()
		print(push_object)
		if push_object.is_in_group("Enemy"):
			print("push")
			var push_direction = (push_point - global_transform.origin).normalized()
			push_object.apply_impulse(Vector3(push_direction.x, push_direction.y, push_direction.z) * 2)
