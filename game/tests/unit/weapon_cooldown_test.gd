extends "res://tests/robot/logic_test_case.gd"

const ActorBase = preload("res://src/shared/scripts/actor_base.gd")
const WeaponBase = preload("res://src/features/weapons/weapon_base.gd")

class TestWeapon extends WeaponBase:
	var fire_count = 0

	func _spawn_ammo(_owner: ActorBase) -> bool:
		fire_count += 1
		return true

func get_name() -> String:
	return "WeaponCooldownTest"

func run_case() -> void:
	var actor = ActorBase.new()
	actor.base_max_hp = 10
	actor.hp = 10
	var weapon = TestWeapon.new()
	weapon.cooldown = 1.0

	for i in range(3):
		weapon.ready_tick(0.4, actor)
		weapon.try_fire(actor)
	assert_equal(weapon.fire_count, 1, "Weapon fires once after full cooldown")

	weapon.ready_tick(0.6, actor)
	weapon.try_fire(actor)
	assert_equal(weapon.fire_count, 2, "Weapon fires again after additional cooldown")
