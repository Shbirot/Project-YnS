extends "res://tests/robot/logic_test_case.gd"

const ActorBase = preload("res://src/shared/scripts/actor_base.gd")
const WeaponBase = preload("res://src/features/weapons/weapon_base.gd")

func get_name() -> String:
	return "ActorWeaponSlotsTest"

func run_case() -> void:
	var actor = ActorBase.new()
	actor.base_max_hp = 10
	actor.hp = 10
	for i in range(6):
		var weapon = WeaponBase.new()
		weapon.id = "weapon_%s" % i
		actor.add_weapon(weapon)
	var equipped = actor.get_equipped_weapons()
	assert_equal(equipped.size(), actor.MAX_WEAPONS, "Weapon slots clamped at max capacity")
