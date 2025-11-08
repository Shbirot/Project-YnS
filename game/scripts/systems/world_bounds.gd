extends RefCounted
class_name WorldBounds

const Log = preload("res://scripts/utils/log_helper.gd")
const Calc = preload("res://scripts/core/calculation_manager.gd")

static var rect := Rect2(-1500, -1500, 3000, 3000)

static func set_rect(new_rect: Rect2) -> void:
	rect = new_rect

static func clamp_position(node: Node2D) -> void:
	if not node:
		return
	node.global_position = Calc.clamp_to_rect(node.global_position, rect)

static func clamp_to_world(body: CharacterBody2D, half_extent: Vector2 = Vector2.ZERO) -> void:
	if not body:
		return
	var new_pos = Calc.clamp_to_rect(body.global_position, rect, half_extent)
	if new_pos != body.global_position:
		Log.debug("WorldBounds blocking %s at %s" % [body.name, new_pos])
	body.global_position = new_pos

static func contains_with_margin(point: Vector2, margin: float = 0.0) -> bool:
	var expanded := Rect2(rect.position - Vector2.ONE * margin, rect.size + Vector2.ONE * margin * 2.0)
	return expanded.has_point(point)
