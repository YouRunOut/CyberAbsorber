extends Node3D
@onready var distance = $Distance

# дебаг кубы, чтобы было видно какой режим укрытия сейчас
@onready var stand_debug = $StandSensor
@onready var crouch_debug = $CrouchSensor

# материалы для дебаг кубов
const GREEN = preload("res://Textures/Materials/Debug/Green.tres")
const RED = preload("res://Textures/Materials/Debug/Red.tres")

# рэйкасты
@onready var StandSightLine = $StandSensor/StandSightLine
@onready var CrouchSightLine = $CrouchSensor/CrouchSightLine

var Target #= Main.player_position
@export var MAX_DISTANCE : float

# зона, обнаруживаемая ИскИнами и наоборот
@onready var CoverArea = $CoverArea

var PlayerNearby : bool = false

# Свободно ли укрытия, чтобы его занять
var PlaceAvailable : bool

# Какой тип укрытия
var CoverType : int

@onready var label_3d = $Label3D

var CoverPosition : Vector3

enum{ # состояния
	NO, # 0
	CROUCH, # 1
	STAND, # 2
	}


func _physics_process(delta):
	if PlayerNearby:
		label_3d.text = str(PlaceAvailable)
		
		# Проверяет доступность и тип укрытия
		register_cover_type()
		
		# Кто находится на месте укрытия
		if CoverArea.monitoring:
			for body in CoverArea.get_overlapping_bodies():
				if body.is_in_group("Player"):
					PlaceAvailable = false
					
				elif body.is_in_group("Enemy_human"):
					if PlaceAvailable:
						if body.has_method("in_cover") and body.State == 6:
							print(body)
							print("Cover")
							body.in_cover(CoverPosition, CoverType)
					else:
						CoverArea.monitorable = false


func is_the_place_available() -> bool:
	# Если доступен - враги видят это укрытие
	if PlaceAvailable:
		CoverArea.visible = true
		CoverArea.monitoring = true
		CoverArea.monitorable = true
	else:
		CoverArea.visible = false
		CoverArea.monitoring = false
		CoverArea.monitorable = false
		
		crouch_debug.visible = false
		stand_debug.visible = false
	return PlaceAvailable


func register_cover_type():
	# Если не видно игрока из позиции сидя, то укрытие доступно
	if not is_the_player_visible(CrouchSightLine):
		crouch_debug.material = GREEN
		crouch_debug.visible = true
		PlaceAvailable = true
		# После
		# Проверяет видимость из положения стоя, если не игрока видно, то укрытие доступно в положении стоя
		if not is_the_player_visible(StandSightLine):
			stand_debug.material = GREEN
			stand_debug.visible = true
			CoverType = STAND
		
		# Иначе только сидя
		else:
			#stand_debug.material = RED
			stand_debug.visible = false
			crouch_debug.visible = true
			CoverType = CROUCH
	
	# В противном случае укрытие недоступно
	else:
		#crouch_debug.material = RED
		crouch_debug.visible = false
		stand_debug.visible = false
		CoverType = NO
		PlaceAvailable = false


func is_the_player_visible(SightLine):
	return raycast_to_player(SightLine) == true
	

func raycast_to_player(raycast) -> bool:
	var dir = global_position.direction_to(Target.global_position)
	raycast.set_target_position(dir * MAX_DISTANCE)
	
	if not str(raycast.get_collider()) == "<Object#null>":
		if raycast.get_collider().is_in_group("Player"): # КОСТЫЛЬ, если без него рэйкастить в пустоту - выдает ошибку
			return true
		else: return false
	else: return false


func _on_distance_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		CoverPosition = get_global_transform().origin
		Target = body
		PlayerNearby = true


func _on_distance_body_exited(body: Node3D):
	if body.is_in_group("Player"): # Если в радиусе укрытия больше нет игрока
		Target = null
		PlayerNearby = false
