extends "res://tests/robot/logic_test_case.gd"

const ProjectileScene = preload("res://scenes/projectiles/tornado_projectile.tscn")

class EnemyStub:
	extends Node2D
	var damage_log: Array = []
	func apply_damage(amount, _source):
		damage_log.append(amount)

func get_name() -> String:
	return "ProjectileLOSPassthrough"

func run_case() -> void:
	var projectile = ProjectileScene.instantiate()
	projectile.damage = 22
	var enemy = EnemyStub.new()
	projectile._on_body_entered(enemy)
	assert_equal(enemy.damage_log.size(), 1, "LOS projectile recorded a hit")
	assert_equal(enemy.damage_log[0], 22, "LOS projectile applied the correct damage value")
	assert_true(not projectile.is_queued_for_deletion(), "LOS projectile kept traveling after contact")
	log_summary("Line-of-sight projectile hit one enemy without despawning, preserving pass-through behavior.")
	projectile.queue_free()
