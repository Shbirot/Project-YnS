extends RefCounted
class_name WorldBounds

const Log = preload("res://scripts/utils/log_helper.gd")

static var rect := Rect2(-1500, -1500, 3000, 3000)

static func set_rect(new_rect: Rect2) -> void:
	rect = new_rect

static func clamp_position(node: Node2D) -> void:
	if not node:
		return
	node.global_position = Vector2(
		clamp(node.global_position.x, rect.position.x, rect.position.x + rect.size.x),
		clamp(node.global_position.y, rect.position.y, rect.position.y + rect.size.y)
	)

static func clamp_to_world(body: CharacterBody2D, half_extent: Vector2 = Vector2.ZERO) -> void:
	if not body:
		return
	var min_x = rect.position.x + half_extent.x
	var max_x = rect.position.x + rect.size.x - half_extent.x
	var min_y = rect.position.y + half_extent.y
	var max_y = rect.position.y + rect.size.y - half_extent.y
	var new_pos = Vector2(
		clamp(body.global_position.x, min_x, max_x),
		clamp(body.global_position.y, min_y, max_y)
	)
	if new_pos != body.global_position:
		Log.debug("WorldBounds blocking %s at %s" % [body.name, new_pos])
	body.global_position = new_pos

static func contains_with_margin(point: Vector2, margin: float = 0.0) -> bool:
	var expanded := Rect2(rect.position - Vector2.ONE * margin, rect.size + Vector2.ONE * margin * 2.0)
	return expanded.has_point(point)
