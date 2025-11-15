extends "res://tests/robot/logic_test_case.gd"

const ActorBase = preload("res://src/shared/scripts/actor_base.gd")
const MeleeHitbox = preload("res://src/features/weapons/melee_hitbox.gd")

func get_name() -> String:
	return "MeleeHitboxTest"

func run_case() -> void:
	var actor = ActorBase.new()
	actor.base_max_hp = 10
	actor.hp = 10

	var single_hit = MeleeHitbox.new()
	single_hit.damage = 2
	single_hit.hit_count = 1
	single_hit._ready()
	single_hit._apply_damage(actor)
	assert_equal(actor.hp, 8.0, "Melee hit reduces HP once")
	single_hit._apply_damage(actor)
	assert_equal(actor.hp, 8.0, "Hit count prevents second hit")

	var infinite_hit = MeleeHitbox.new()
	infinite_hit.damage = 1
	infinite_hit.hit_count = -1
	infinite_hit._ready()
	infinite_hit._apply_damage(actor)
	infinite_hit._apply_damage(actor)
	assert_equal(actor.hp, 6.0, "Infinite hitbox deals multiple hits")
