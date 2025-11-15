extends "res://tests/robot/logic_test_case.gd"

const HeroScene := preload("res://scenes/rework/hero.tscn")
const OrbScene := preload("res://scenes/rework/xp_orb.tscn")
const SingletonUtil := preload("res://scripts/utils/singleton_util.gd")

func get_name() -> String:
	return "XPCollection"

func run_case() -> void:
	var tree := get_tree_ref()
	var world := Node2D.new()
	world.name = "XPCollectionWorld"
	var previous_scene := tree.current_scene
	tree.root.add_child(world)
	tree.current_scene = world

	var hero: Node = HeroScene.instantiate()
	world.add_child(hero)

	var orb: Node = OrbScene.instantiate()
	world.add_child(orb)

	var level_manager: Node = SingletonUtil.get_level_manager()
	level_manager.current_xp = 0
	level_manager.current_level = 1

	orb._collect()
	assert_equal(level_manager.current_xp, orb.xp_value, "XP collected increased LevelManager XP")

	tree.root.remove_child(world)
	world.queue_free()
	tree.current_scene = previous_scene
