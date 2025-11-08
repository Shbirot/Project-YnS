extends "res://tests/robot/logic_test_case.gd"

const ProjectileScene = preload("res://scenes/projectiles/tornado_projectile.tscn")

class EnemyStub:
	extends Node2D
	var damage := 0
	func apply_damage(amount, _source):
		damage += amount

func get_name() -> String:
	return "ProjectileLOSDamageAll"

func run_case() -> void:
	var projectile = ProjectileScene.instantiate()
	projectile.damage = 15
	var enemy_a = EnemyStub.new()
	var enemy_b = EnemyStub.new()
	projectile._on_body_entered(enemy_a)
	projectile._on_body_entered(enemy_b)
	assert_equal(enemy_a.damage, 15, "First enemy took LOS damage")
	assert_equal(enemy_b.damage, 15, "Second enemy also took LOS damage")
	assert_true(not projectile.is_queued_for_deletion(), "Projectile stayed alive to reach multiple enemies")
	log_summary("LOS projectile damaged two sequential enemies without despawning or skipping hits.")
	projectile.queue_free()
