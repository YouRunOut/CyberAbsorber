extends Node3D
@onready var distance: Area3D = %Distance

# дебаг кубы, чтобы было видно какой режим укрытия сейчас
@onready var stand_debug: CSGBox3D = %StandSensor
@onready var crouch_debug: CSGBox3D = %CrouchSensor

# материалы для дебаг кубов
@export var green_material: Material
@export var red_material: Material

# рэйкасты
@onready var stand_sight_line: RayCast3D = %StandSightLine
@onready var crouch_sight_line: RayCast3D = %CrouchSightLine

var Target #= Main.player_position
@export var MAX_DISTANCE : float

# зона, обнаруживаемая ИскИнами и наоборот
@onready var cover_area: Area3D = %CoverArea

var PlayerNearby : bool = false

# Свободно ли укрытия, чтобы его занять
var PlaceAvailable : bool

# Какой тип укрытия
var CoverType : int

@onready var label_3d: Label3D = %Label3D

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
		if cover_area.monitoring:
			for body in cover_area.get_overlapping_bodies():
				if body.is_in_group("Player"):
					PlaceAvailable = false
					
				elif body.is_in_group("Enemy_human"):
					if PlaceAvailable:
						if body.State == 6:
							print(body)
							print("Cover")
							body.in_cover(CoverPosition, CoverType)
					else:
						cover_area.monitorable = false


func is_the_place_available() -> bool:
	# Если доступен - враги видят это укрытие
	if PlaceAvailable:
		cover_area.visible = true
		cover_area.monitoring = true
		cover_area.monitorable = true
	else:
		cover_area.visible = false
		cover_area.monitoring = false
		cover_area.monitorable = false
		
		crouch_debug.visible = false
		stand_debug.visible = false
	return PlaceAvailable


func register_cover_type():
	# Если не видно игрока из позиции сидя, то укрытие доступно
	if not is_the_player_visible(crouch_sight_line):
		crouch_debug.material = green_material
		crouch_debug.visible = true
		PlaceAvailable = true
		# После
		# Проверяет видимость из положения стоя, если не игрока видно, то укрытие доступно в положении стоя
		if not is_the_player_visible(stand_sight_line):
			stand_debug.material = green_material
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
