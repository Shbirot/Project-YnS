extends "res://tests/robot/logic_test_case.gd"

const AmmoScript = preload("res://scripts/weapons/projectile_ammunition.gd")
const ProjectileScene = preload("res://scenes/projectiles/magic_spark_projectile.tscn")

func get_name() -> String:
	return "ProjectileAmmunitionFallback"

func run_case() -> void:
	var ammo := AmmoScript.new()
	ammo.projectile_scene = ProjectileScene
	var tree := get_tree_ref()
	if tree == null:
		push_result(false, "SceneTree unavailable for fallback test")
		return
	var container := Node2D.new()
	tree.root.add_child(container)
	var previous_scene = tree.current_scene
	tree.current_scene = container
	var before := container.get_child_count()
	ammo.fire(Vector2.ZERO, Vector2.RIGHT, {"speed": 0})
	var after := container.get_child_count()
	assert_equal(after, before + 1, "Projectile attached to current scene when no parent provided")
	var projectile = container.get_child(after - 1)
	projectile.queue_free()
	container.queue_free()
	tree.current_scene = previous_scene
	log_summary("ProjectileAmmunition fell back to current scene (children %d→%d)." % [before, after])
