extends "res://tests/robot/logic_test_case.gd"

const ProjectileAmmunition = preload("res://scripts/weapons/projectile_ammunition.gd")
const MagicSparkScene = preload("res://scenes/projectiles/magic_spark_projectile.tscn")

func get_name() -> String:
	return "WeaponAmmunition"

func run_case() -> void:
	var ammo = ProjectileAmmunition.new()
	ammo.projectile_scene = MagicSparkScene
	var parent = Node2D.new()
	Engine.get_main_loop().root.add_child(parent)
	ammo.fire(Vector2.ZERO, Vector2.RIGHT, {
		"speed": 500,
		"damage": 25,
		"damage_type": "magic_arcane",
		"source": null,
		"parent": parent,
	})
	assert_true(parent.get_child_count() == 1, "Projectile spawned under parent")
	var projectile = parent.get_child(0)
	assert_equal(projectile.damage, 25, "Damage override applied")
	parent.queue_free()
	log_summary("Fired ProjectileAmmunition into a dummy parent and validated spawn count plus damage override propagation.")
