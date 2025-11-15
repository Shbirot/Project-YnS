extends "res://tests/robot/logic_test_case.gd"

const ProjectileScene = preload("res://src/features/projectiles/projectile_basic.tscn")
const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")

func get_name() -> String:
	return "ProjectilePool"

func run_case() -> void:
	var pool = SingletonUtil.get_projectile_pool()
	assert_true(pool != null, "ProjectilePool singleton available")
	var first = pool.fetch_projectile(ProjectileScene)
	assert_true(first != null, "Fetched projectile instance")
	pool.recycle_projectile(first)
	var second = pool.fetch_projectile(ProjectileScene)
	assert_true(second == first, "Pool reused projectile instance")
