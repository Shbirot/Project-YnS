extends "res://tests/robot/logic_test_case.gd"

const HeroScene = preload("res://src/features/player/hero.tscn")
const AuraScene = preload("res://src/features/weapons/environmental_aura.tscn")

func get_name() -> String:
	return "EnvironmentalWeaponDamageTest"

func run_case() -> void:
	var tree = get_tree_ref()
	var world = Node2D.new()
	tree.root.add_child(world)
	tree.current_scene = world
	var hero = HeroScene.instantiate()
	world.add_child(hero)
	var aura = AuraScene.instantiate()
	world.add_child(aura)
	aura.global_position = hero.global_position
	aura.owner_ref = hero
	aura.damage = 3
	var starting_hp = hero.hp
	aura._apply_damage(hero)
	assert_true(hero.hp < starting_hp, "Aura damage reduced hero HP")
	tree.root.remove_child(world)
	world.queue_free()
