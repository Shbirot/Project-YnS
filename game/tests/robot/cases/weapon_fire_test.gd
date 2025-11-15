extends "res://tests/robot/logic_test_case.gd"

const HeroScene = preload("res://src/features/player/hero.tscn")
const WeaponResource = preload("res://src/features/weapons/basic_wand.tres")

func get_name() -> String:
	return "HeroWeaponFire"

var _projectile_detected = false

func _on_projectile_fired(_projectile: Node) -> void:
	_projectile_detected = true

func run_case() -> void:
	var tree = get_tree_ref()
	var world = Node2D.new()
	world.name = "WeaponFireWorld"
	var previous_scene = tree.current_scene
	tree.root.add_child(world)
	tree.current_scene = world

	var hero = HeroScene.instantiate()
	world.add_child(hero)
	hero.set_input_override(Vector2.RIGHT)
	var weapon = WeaponResource.duplicate(true)
	var before = _count_projectiles(world)
	weapon.try_fire(hero)
	var after = _count_projectiles(world)
	assert_true(after > before, "Hero weapon fired projectile into scene")

	tree.root.remove_child(world)
	world.queue_free()
	tree.current_scene = previous_scene

func _count_projectiles(world: Node) -> int:
	var count = 0
	for child in world.get_children():
		if child is Area2D and child.has_variable("owner_ref"):
			count += 1
	return count
