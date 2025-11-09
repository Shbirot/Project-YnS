extends Node

class_name AttributesManager

const Log = preload("res://scripts/utils/log_helper.gd")

## Hero HP state (separate from general attributes)
var _current_hp: int = 100
var _max_hp: int = 100

## General hero attributes (stats)
var _attributes := {
	"fire_rate": 0.6,
	"projectile_speed": 700.0,
	"crit_rate": 0.05,
	"crit_multiplier": 1.35,
}

## ============================================
## HP Management (Hero only)
## ============================================

func get_current_hp() -> int:
	return _current_hp

func get_max_hp() -> int:
	return _max_hp

func set_max_hp(value: int) -> void:
	_max_hp = max(1, value)
	_current_hp = min(_current_hp, _max_hp)
	Log.info("AttributesManager: max_hp set to %d (current=%d)" % [_max_hp, _current_hp])

func set_current_hp(value: int) -> void:
	_current_hp = clamp(value, 0, _max_hp)
	Log.debug("AttributesManager: hp set to %d/%d" % [_current_hp, _max_hp])

func apply_damage(amount: int) -> int:
	if amount <= 0:
		return _current_hp
	var old_hp = _current_hp
	_current_hp = max(_current_hp - amount, 0)
	Log.info("AttributesManager: hero took %d damage (%d->%d)" % [amount, old_hp, _current_hp])
	return _current_hp

func heal(amount: int) -> int:
	if amount <= 0:
		return _current_hp
	var old_hp = _current_hp
	_current_hp = min(_current_hp + amount, _max_hp)
	Log.info("AttributesManager: hero healed %d (%d->%d)" % [amount, old_hp, _current_hp])
	return _current_hp

func is_dead() -> bool:
	return _current_hp <= 0

## ============================================
## General Attributes (stats)
## ============================================

func reset_attributes(defaults: Dictionary = {}) -> void:
	_attributes = defaults.duplicate()
	Log.info("AttributesManager: reset %d attributes" % _attributes.size())

func get_attribute(name: String, default_value = 0.0):
	return _attributes.get(name, default_value)

func set_attribute(name: String, value) -> void:
	_attributes[name] = value
	Log.debug("AttributesManager: set %s=%s" % [name, value])

func modify_attribute(name: String, delta) -> void:
	_attributes[name] = get_attribute(name, 0.0) + delta
	Log.debug("AttributesManager: modify %s by %s -> %s" % [name, delta, _attributes[name]])

func get_all_attributes() -> Dictionary:
	var all = _attributes.duplicate()
	# Include HP in legacy format for backward compatibility
	all["hp"] = float(_current_hp)
	all["max_hp"] = float(_max_hp)
	return all
