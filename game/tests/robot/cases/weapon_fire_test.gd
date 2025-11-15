extends "res://tests/robot/logic_test_case.gd"

const HeroScene := preload("res://scenes/rework/hero.tscn")

func get_name() -> String:
	return "HeroWeaponFire"

func run_case() -> void:
	var tree := get_tree_ref()
	var world := Node2D.new()
	world.name = "WeaponFireWorld"
	var previous_scene := tree.current_scene
	tree.root.add_child(world)
	tree.current_scene = world

	var hero := HeroScene.instantiate()
	world.add_child(hero)

	hero.set_input_override(Vector2.RIGHT)
	var existing_children := world.get_child_count()
	hero._fire_weapon()

	var projectile_spawned := world.get_child_count() > existing_children
	assert_true(projectile_spawned, "Hero fired projectile into world")

	tree.root.remove_child(world)
	world.queue_free()
	tree.current_scene = previous_scene
