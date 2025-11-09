extends RefCounted

class_name CombatSystem

const Calc = preload("res://scripts/core/calculation_manager.gd")
const SingletonUtil = preload("res://scripts/utils/singleton_util.gd")
const Log = preload("res://scripts/utils/log_helper.gd")

## Apply damage to a target
## Routes hero damage through APIManager, monsters use local HP
static func apply_damage(target, amount: int, source = null) -> void:
	if amount <= 0 or not is_instance_valid(target):
		return

	# Route damage based on target type
	if target.is_in_group("heroes"):
		# Heroes: route through APIManager
		var api = SingletonUtil.get_api_manager()
		if api:
			api.damage_hero(amount, source)
	else:
		# Monsters: use local HP
		if target.has_method("apply_damage"):
			target.apply_damage(amount, source)

static func tick_cooldown(current: float, delta: float) -> float:
	return Calc.tick_cooldown(current, delta)

## Try to apply contact damage if cooldown is ready
## Returns true if damage was applied
static func try_contact_damage(attacker, target, amount: int, cooldown_ready: bool) -> bool:
	if not cooldown_ready:
		return false
	if not is_instance_valid(target):
		return false

	# Route damage based on target type
	if target.is_in_group("heroes"):
		# Heroes: route through APIManager
		var api = SingletonUtil.get_api_manager()
		if api:
			api.damage_hero(amount, attacker)
			return true
		else:
			Log.error("CombatSystem: APIManager not available for hero contact damage!")
			return false
	else:
		# Monsters: use local HP
		if target.has_method("apply_damage"):
			target.apply_damage(amount, attacker)
			return true
		return false
