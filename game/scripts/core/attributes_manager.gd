extends Node

class_name AttributesManager

const Log = preload("res://scripts/utils/log_helper.gd")

var _values := {
	"hp": 100.0,
	"fire_rate": 0.6,
	"projectile_speed": 700.0,
	"crit_rate": 0.05,
	"crit_multiplier": 1.35,
}

func reset(defaults: Dictionary = {}) -> void:
	_values = defaults.duplicate()
	Log.info("AttributesManager reset (%d attributes)" % _values.size())

func get_attribute(name: String, default_value = 0) -> float:
	return _values.get(name, default_value)

func set_attribute(name: String, value) -> void:
	_values[name] = value
	Log.debug("AttributesManager set %s=%s" % [name, value])

func modify_attribute(name: String, delta) -> void:
	_values[name] = get_attribute(name, 0) + delta
	Log.debug("AttributesManager modify %s by %s -> %s" % [name, delta, _values[name]])

func get_all_attributes() -> Dictionary:
	return _values.duplicate()
