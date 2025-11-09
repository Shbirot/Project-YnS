extends RefCounted

class_name DamageSystem

const Log = preload("res://scripts/utils/log_helper.gd")
const Calc = preload("res://scripts/core/calculation_manager.gd")
const SingletonUtil = preload("res://scripts/utils/singleton_util.gd")

## Apply projectile damage to a target
## Routes hero damage through APIManager, monsters use local HP
static func apply_projectile_damage(target: Node, base_damage: float, damage_type: String, hit_position: Vector2, source = null) -> void:
	if target == null:
		Log.warn("DamageSystem: target nil for damage_type=%s" % damage_type)
		return

	var metrics = _calculate_final_damage(base_damage)
	var final_damage = int(metrics.damage)

	# Route damage based on target type
	if target.is_in_group("heroes"):
		# Heroes: route through APIManager
		_damage_hero(final_damage, source)
	else:
		# Monsters: use local HP
		if target.has_method("apply_damage"):
			target.apply_damage(final_damage, source)

	# Show damage number visual effect
	var api = SingletonUtil.get_api_manager()
	if api:
		api.show_damage_number(final_damage, damage_type, metrics.is_crit, hit_position)

## Damage hero through APIManager
## APIManager handles HP updates, signals, and death detection
static func _damage_hero(amount: int, source) -> void:
	var api = SingletonUtil.get_api_manager()
	if api:
		api.damage_hero(amount, source)
	else:
		Log.error("DamageSystem: APIManager not available for hero damage!")

## Calculate final damage with crit roll
static func _calculate_final_damage(base_damage: float) -> Dictionary:
	var crit_rate := 0.05
	var crit_multiplier := 1.35

	# Get crit stats from hero attributes
	var api = SingletonUtil.get_api_manager()
	if api:
		crit_rate = api.get_hero_attribute("crit_rate", crit_rate)
		crit_multiplier = api.get_hero_attribute("crit_multiplier", crit_multiplier)

	return Calc.roll_damage(base_damage, crit_rate, crit_multiplier)
