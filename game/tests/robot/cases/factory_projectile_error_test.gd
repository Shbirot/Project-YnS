extends "res://tests/robot/logic_test_case.gd"

const ProjectileFactory = preload("res://scripts/factories/projectile_factory.gd")

func get_name() -> String:
	return "FactoryProjectileError"

func run_case() -> void:
	var bad_spec := {
		"id": "projectile_missing_scene",
		"scene": "res://scenes/projectiles/ghost_bolt.tscn",
	}
	var factory = ProjectileFactory.new()
	var projectile = factory.create(bad_spec)
	assert_true(projectile == null, "ProjectileFactory returns null for missing projectile scenes")
	log_summary("ProjectileFactory failed fast when a projectile spec referenced an unknown scene path.")
