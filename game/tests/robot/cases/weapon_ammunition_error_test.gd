extends "res://tests/robot/logic_test_case.gd"

const ProjectileAmmunition = preload("res://scripts/weapons/projectile_ammunition.gd")

func get_name() -> String:
	return "WeaponAmmunitionError"

func run_case() -> void:
	var ammo = ProjectileAmmunition.new()
	var parent = Node2D.new()
	ammo.fire(Vector2.ZERO, Vector2.RIGHT, {
		"speed": 400.0,
		"damage": 12,
		"damage_type": "magic_arcane",
		"parent": parent,
	})
	assert_equal(parent.get_child_count(), 0, "No projectile spawns when projectile_scene is missing")
	log_summary("ProjectileAmmunition gracefully skipped firing when no projectile_scene was configured.")
