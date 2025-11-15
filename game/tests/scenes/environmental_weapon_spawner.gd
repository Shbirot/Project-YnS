extends Node

const EnvironmentalWeapon = preload("res://src/features/weapons/environmental_weapon.gd")

@export var weapon: EnvironmentalWeapon
@export var owner_path: NodePath

func _ready() -> void:
	if weapon == null or owner_path.is_empty():
		return
	var owner = get_node_or_null(owner_path)
	if owner == null:
		return
	weapon.try_fire(owner)
