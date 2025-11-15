extends "res://tests/robot/logic_test_case.gd"

const MainScene = preload("res://src/levels/main.tscn")

func get_name() -> String:
	return "WorldBoot"

func run_case() -> void:
	var tree = get_tree_ref()
	assert_true(tree != null, "SceneTree available for tests")
	var previous_scene = tree.current_scene
	var world = MainScene.instantiate()
	tree.root.add_child(world)
	tree.current_scene = world

	var hero = world.get_node_or_null("Hero")
	assert_true(hero != null, "Hero node is present in main scene")

	var spawner = world.get_node_or_null("SpawnerController")
	assert_true(spawner != null, "SpawnerController exists")

	var hud = world.get_node_or_null("HUD")
	assert_true(hud != null, "HUD exists in scene tree")

	tree.root.remove_child(world)
	world.queue_free()
	tree.current_scene = previous_scene
