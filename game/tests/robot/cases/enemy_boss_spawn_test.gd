extends "res://tests/robot/logic_test_case.gd"

const BossScene = preload("res://tests/scenes/boss_test_scene.tscn")

func get_name() -> String:
	return "EnemyBossSpawnTest"

func run_case() -> void:
	var tree = get_tree_ref()
	var world = BossScene.instantiate()
	tree.root.add_child(world)
	tree.current_scene = world
	var boss = world.get_node_or_null("Boss")
	assert_true(boss != null, "Boss node spawned")
	boss.apply_damage(999.0, self)
	assert_false(boss.is_alive, "Boss died after large damage")
	tree.root.remove_child(world)
	world.queue_free()
