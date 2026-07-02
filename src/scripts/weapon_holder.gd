extends Node3D
class_name MF_WeaponHolder

signal shoot
signal reload
signal equip_weapon
signal hide_weapon

@export var equipped_weapon: Node3D


func emit_shoot() -> void:
	emit_signal("shoot")


func emit_reload() -> void:
	emit_signal("reload")


func emit_equip_weapon() -> void:
	emit_signal("equip_weapon")


func emit_hide_weapon() -> void:
	emit_signal("hide_weapon")
