extends "res://tests/robot/logic_test_case.gd"

const EnemyArchetypeRegistry = preload("res://src/features/enemy/enemy_archetype_registry.gd")
const MonsterBase = preload("res://src/features/enemy/monster_base.gd")

func get_name() -> String:
	return "EnemyArchetypeSpawnTest"

func run_case() -> void:
	var registry = EnemyArchetypeRegistry.load_archetypes("res://config/enemies")
	assert_true(registry.has("basic_swarmer"), "Basic archetype present")
	assert_true(registry.has("elite_ranger"), "Elite archetype present")

	var basic_archetype = registry["basic_swarmer"]
	var elite_archetype = registry["elite_ranger"]

	var basic_enemy = MonsterBase.new()
	basic_enemy.configure_from_archetype(basic_archetype)
	basic_enemy.prepare_for_spawn(Vector2.ZERO)
	assert_equal(basic_enemy.base_max_hp, 20.0, "Basic archetype applied stats")
	assert_equal(basic_enemy.get_equipped_weapons().size(), 0, "Basic archetype has no weapons")

	var elite_enemy = MonsterBase.new()
	elite_enemy.configure_from_archetype(elite_archetype)
	elite_enemy.prepare_for_spawn(Vector2.ZERO)
	assert_true(elite_enemy.base_max_hp >= 40.0, "Elite archetype applied higher HP")
	assert_true(elite_enemy.get_equipped_weapons().size() >= 1, "Elite archetype equips ranged weapon")
