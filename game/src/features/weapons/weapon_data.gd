extends Resource
class_name WeaponDataRework

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")

enum AttackType { RANGED, MELEE }

@export var display_name := "Basic Wand"
@export var description := "Fires slow-moving bolts."
@export var attack_type := AttackType.RANGED
@export var projectile_scene: PackedScene
@export var melee_scene: PackedScene
@export var fire_interval := 0.6
@export var damage := 1.0
@export var projectile_speed := 600.0
@export var projectiles_per_shot := 1
@export var spread_degrees := 0.0
@export var attack_range := 32.0
@export var env_prefix := "NF_WEAPON_BASIC_WAND"

func is_valid() -> bool:
	if attack_type == AttackType.MELEE:
		return melee_scene != null and fire_interval > 0.0
	return projectile_scene != null and fire_interval > 0.0

func is_melee() -> bool:
	return attack_type == AttackType.MELEE

func get_fire_interval_value() -> float:
	return _env_value("FIRE_INTERVAL", fire_interval)

func get_damage_value() -> float:
	return _env_value("DAMAGE", damage)

func get_projectile_speed_value() -> float:
	return _env_value("PROJECTILE_SPEED", projectile_speed)

func get_attack_range_value() -> float:
	return _env_value("ATTACK_RANGE", attack_range)

func _env_value(suffix: String, default_value):
	var cfg = SingletonUtil.get_game_config()
	var key := "%s_%s" % [env_prefix, suffix]
	return cfg.get_env_value(key, default_value)
