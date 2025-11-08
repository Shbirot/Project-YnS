extends "res://tests/robot/logic_test_case.gd"

const Weapon = preload("res://scripts/weapons/weapon.gd")

class HeroStub:
	extends Object
	var fire_interval := 0.3
	var projectile_scene
	var projectile_speed := 500
	var base_damage := 5
	var damage_type := "physical"
	var ammunition

	func set_fire_interval_value(value):
		fire_interval = value

	func set_ammunition(value):
		ammunition = value

	func set_damage_type(value):
		damage_type = value

func get_name() -> String:
	return "WeaponApplication"

func run_case() -> void:
	var hero = HeroStub.new()
	var weapon_res: Resource = load("res://resources/weapons/basic_wand.tres")
	weapon_res.apply_to(hero)
	assert_equal(hero.fire_interval, weapon_res.firing_rate, "fire interval transferred")
	assert_true(hero.projectile_scene != null, "projectile scene assigned")
	assert_equal(hero.damage_type, "magic_arcane", "damage type propagated")
	log_summary("Applied basic_wand resource to a hero stub and confirmed firing rate, projectile scene, and damage type transfer.")
