extends "res://tests/robot/logic_test_case.gd"

const AmmoBase = preload("res://src/features/weapons/ammo_base.gd")

func get_name() -> String:
	return "AmmoLifetimeTest"

func run_case() -> void:
	var ammo = AmmoBase.new()
	ammo.lifetime = 0.5
	ammo._ready()
	ammo._physics_process(0.3)
	assert_false(ammo.is_queued_for_deletion(), "Ammo persists before lifetime expires")
	ammo._physics_process(0.3)
	assert_true(ammo.is_queued_for_deletion(), "Ammo despawns after exceeding lifetime")
