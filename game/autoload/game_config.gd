extends Node

## Lightweight runtime config loader shared across dev/stage/prod exports.

var profile : String = "dev"
var settings := {
	"dev": {
		"enemy_spawn_rate": 1.4,
		"xp_multiplier": 1.0,
		"analytics_enabled": false,
		"steam_enabled": false,
	},
	"stage": {
		"enemy_spawn_rate": 1.1,
		"xp_multiplier": 1.0,
		"analytics_enabled": false,
		"steam_enabled": false,
	},
	"prod": {
		"enemy_spawn_rate": 1.0,
		"xp_multiplier": 1.1,
		"analytics_enabled": true,
		"steam_enabled": true,
	},
}

func _ready() -> void:
	profile = _deduce_profile()
	if not settings.has(profile):
		push_warning("Unknown NIGHTFALL_ENV '%s'. Falling back to dev." % profile)
		profile = "dev"

func get_setting(name: String, default_value = null):
	var env_settings = settings.get(profile, {})
	if env_settings.has(name):
		return env_settings[name]
	return default_value

func _deduce_profile() -> String:
	if OS.has_environment("NIGHTFALL_ENV"):
		return OS.get_environment("NIGHTFALL_ENV")
	return "dev"
