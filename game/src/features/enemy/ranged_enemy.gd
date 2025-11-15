extends "res://src/features/enemy/monster_base.gd"

@export var ranged_weapon = null

func _on_monster_ready() -> void:
	if ranged_weapon:
		set_weapon_overrides([ranged_weapon])
