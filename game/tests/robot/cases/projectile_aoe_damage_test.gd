extends "res://tests/robot/logic_test_case.gd"

const ProjectileScene = preload("res://scenes/projectiles/fireball_projectile.tscn")

class EnemyStub:
	extends Node2D
	var damage := 0
	func apply_damage(amount, _source):
		damage += amount

func get_name() -> String:
	return "ProjectileAOEDamage"

func run_case() -> void:
	var projectile = ProjectileScene.instantiate()
	projectile.damage = 40
	var inside := EnemyStub.new()
	var outside := EnemyStub.new()
	inside.global_position = Vector2(10, 0)
	outside.global_position = Vector2(400, 0)
	projectile.debug_damage_area([inside, outside], Vector2.ZERO, 120.0)
	assert_equal(inside.damage, 40, "Enemy inside radius took AOE damage")
	assert_equal(outside.damage, 0, "Enemy outside radius stayed unharmed")
	log_summary("AOE projectile applied damage within 120px radius while leaving distant enemies untouched.")
	projectile.queue_free()
