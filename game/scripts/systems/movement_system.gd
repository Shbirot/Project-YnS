extends RefCounted

class_name MovementSystem

static func apply_directional_input(body: CharacterBody2D, direction: Vector2, speed: float) -> void:
	if not body:
		return
	var target_velocity = direction.normalized() * speed if direction != Vector2.ZERO else Vector2.ZERO
	body.velocity = target_velocity
	_move_body_if_ready(body)

static func apply_input_with_accel(body: CharacterBody2D, direction: Vector2, speed: float, accel: float, friction: float, delta: float) -> void:
	if not body:
		return
	if direction == Vector2.ZERO:
		body.velocity = body.velocity.move_toward(Vector2.ZERO, friction * delta)
	else:
		var target = direction.normalized() * speed
		body.velocity = body.velocity.move_toward(target, accel * delta)
	_move_body_if_ready(body)

static func seek_target(body: CharacterBody2D, target: Node2D, speed: float) -> void:
	if not body or not is_instance_valid(target):
		body.velocity = Vector2.ZERO
		return
	var dir = (target.global_position - body.global_position).normalized()
	apply_directional_input(body, dir, speed)

static func _move_body_if_ready(body: CharacterBody2D) -> void:
	if body.is_inside_tree():
		body.move_and_slide()
