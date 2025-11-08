extends "res://scripts/factories/base_object_factory.gd"

class_name HeroFactory

func _apply_special_property(target: Object, key: String, value) -> bool:
	if key == "equipped_weapon":
		if typeof(value) == TYPE_STRING and value != "" and ResourceLoader.exists(value):
			var resource: Resource = ResourceLoader.load(value)
			if resource:
				target.set(key, resource)
				return true
		elif value is Resource:
			target.set(key, value)
			return true
	return false
