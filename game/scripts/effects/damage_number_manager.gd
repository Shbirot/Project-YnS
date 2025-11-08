extends Node

class_name DamageNumberManager

const PhysicalNumber = preload("res://scenes/ui/damage_numbers/physical_damage_number.tscn")
const MagicNumber = preload("res://scenes/ui/damage_numbers/magic_damage_number.tscn")
const PhysicalCritNumber = preload("res://scenes/ui/damage_numbers/physical_crit_damage_number.tscn")
const MagicCritNumber = preload("res://scenes/ui/damage_numbers/magic_crit_damage_number.tscn")

func show_damage(amount: float, damage_type: String, is_crit: bool, position: Vector2) -> void:
	var scene = _resolve_scene(damage_type, is_crit)
	if scene == null:
		return
	var node = scene.instantiate()
	var parent = get_tree().current_scene
	if parent:
		parent.add_child(node)
	else:
		add_child(node)
	if node.has_method("configure"):
		node.configure(amount, position, damage_type, is_crit)

func _resolve_scene(damage_type: String, is_crit: bool):
	var is_magic = damage_type.begins_with("magic")
	if is_magic and is_crit:
		return MagicCritNumber
	if is_magic:
		return MagicNumber
	if is_crit:
		return PhysicalCritNumber
	return PhysicalNumber
