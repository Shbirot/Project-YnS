extends "res://tests/robot/logic_test_case.gd"

const HeroScene = preload("res://src/features/player/hero.tscn")
const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")

func get_name() -> String:
	return "XPCollection"

func run_case() -> void:
	var tree = get_tree_ref()
	var world = Node2D.new()
	world.name = "XPCollectionWorld"
	var previous_scene = tree.current_scene
	tree.root.add_child(world)
	tree.current_scene = world

	var hero: Node = HeroScene.instantiate()
	world.add_child(hero)

	var level_manager: Node = SingletonUtil.get_level_manager()
	level_manager.current_xp = 0
	level_manager.current_level = 1

	level_manager.call("add_xp", 10)
	assert_equal(level_manager.current_xp, 10, "XP collected increased LevelManager XP")

	tree.root.remove_child(world)
	world.queue_free()
	tree.current_scene = previous_scene
