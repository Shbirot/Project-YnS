extends RefCounted
class_name BaseObjectFactory

const TypeUtil = preload("res://scripts/utils/type_util.gd")

func create(spec: Dictionary) -> Node:
	var scene_path: String = spec.get("scene", "")
	if scene_path == "":
		push_warning("Factory spec missing 'scene': %s" % spec.get("id", "<unknown>"))
		return null
	if not ResourceLoader.exists(scene_path):
		push_warning("Factory could not find scene %s" % scene_path)
		return null
	var packed: PackedScene = ResourceLoader.load(scene_path)
	if packed == null:
		push_warning("Factory failed to load scene %s" % scene_path)
		return null
	var instance: Node = packed.instantiate()
	instance.name = spec.get("id", instance.name)
	_apply_properties(instance, spec.get("properties", {}))
	instance.set_meta("factory_spec", spec)
	return instance

func _apply_properties(target: Object, properties: Dictionary) -> void:
	if properties.is_empty():
		return
	var property_names := _get_property_name_set(target)
	for key in properties.keys():
		var value = TypeUtil.coerce_value(properties[key])
		if property_names.has(key):
			target.set(key, value)
		elif _apply_special_property(target, key, value):
			continue
		else:
			# Silently ignore unknown properties to keep YAML flexible.
			continue

func _apply_special_property(_target: Object, _key: String, _value) -> bool:
	return false

func _get_property_name_set(target: Object) -> Dictionary:
	var names := {}
	for prop in target.get_property_list():
		names[prop.get("name")] = true
	return names

