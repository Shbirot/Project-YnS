extends Resource
class_name StatBlock

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")

@export var env_prefix := "NF_STATS_GENERIC"
@export var max_hp := 100.0
@export var attack := 10.0
@export var defense := 0.0
@export var crit_rate := 0.0
@export var crit_damage := 150.0
@export var speed := 200.0
@export var attack_speed := 1.0
@export var avoid_chance := 0.0
@export var luck := 0.0
@export var hp_regen := 0.0
@export var exp_rate := 1.0

func get_stats() -> Dictionary:
	var stats := {
		"max_hp": max_hp,
		"attack": attack,
		"defense": defense,
		"crit_rate": crit_rate,
		"crit_damage": crit_damage,
		"speed": speed,
		"attack_speed": attack_speed,
		"avoid_chance": avoid_chance,
		"luck": luck,
		"hp_regen": hp_regen,
		"exp_rate": exp_rate,
	}
	var cfg = SingletonUtil.get_game_config()
	for key in stats.keys():
		var env_key := "%s_%s" % [env_prefix, str(key).to_upper()]
		stats[key] = cfg.get_env_value(env_key, stats[key])
	return stats
