extends Resource
class_name WeaponDataRework

const SingletonUtil = preload("res://scripts/utils/singleton_util.gd")

@export var display_name := "Basic Wand"
@export var description := "Fires slow-moving bolts."
@export var projectile_scene: PackedScene
@export var fire_interval := 0.6
@export var damage := 5.0
@export var projectile_speed := 600.0
@export var projectiles_per_shot := 1
@export var spread_degrees := 0.0
@export var env_prefix := "NF_WEAPON_BASIC_WAND"

func is_valid() -> bool:
	return projectile_scene != null and fire_interval > 0.0

func get_fire_interval_value() -> float:
	return _env_value("FIRE_INTERVAL", fire_interval)

func get_damage_value() -> float:
	return _env_value("DAMAGE", damage)

func get_projectile_speed_value() -> float:
	return _env_value("PROJECTILE_SPEED", projectile_speed)

func _env_value(suffix: String, default_value):
	var cfg = SingletonUtil.get_game_config()
	var key := "%s_%s" % [env_prefix, suffix]
	return cfg.get_env_value(key, default_value)
