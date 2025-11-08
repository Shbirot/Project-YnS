extends "res://scripts/weapons/ammunition_base.gd"
class_name ProjectileAmmunition

@export var projectile_scene : PackedScene

func fire(origin: Vector2, direction: Vector2, context: Dictionary = {}) -> void:
	if projectile_scene == null:
		return
	var projectile = projectile_scene.instantiate()
	projectile.global_position = origin
	projectile.direction = direction
	if context.has("speed"):
		_set_if_exists(projectile, "speed", context["speed"])
	if context.has("damage"):
		_set_if_exists(projectile, "damage", context["damage"])
	if context.has("damage_type"):
		_set_if_exists(projectile, "damage_type", context["damage_type"])
	if context.has("source"):
		_set_if_exists(projectile, "damage_source", context["source"])
	var parent = context.get("parent")
	if parent is Node:
		parent.add_child(projectile)
		return
	var loop := Engine.get_main_loop()
	if loop is SceneTree:
		var scene_root: Node = loop.current_scene
		if scene_root:
			scene_root.add_child(projectile)
func _set_if_exists(target: Object, property_name: String, value) -> void:
	for prop in target.get_property_list():
		if prop.get("name") == property_name:
			target.set(property_name, value)
			return
