extends MF_BaseWeapon

@onready var load: MeshInstance3D = %Load
@onready var ammo_count: Label3D = %AmmoCount


func _process(delta):
	if reloading:
		ammo_count.text = "RLD"
	else:
		if AMMO == 0:
			load.position = lerp(load.position, Vector3(0, 0.32, 0.103), delta * 30)
			ammo_count.text = "R"
		else:
			ammo_count.text = str(AMMO)
