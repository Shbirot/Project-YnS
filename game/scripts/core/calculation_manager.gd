extends RefCounted
class_name CalculationManager

static var _rng := RandomNumberGenerator.new()

static func get_random_int(min_val: int, max_val: int) -> int:
	return _rng.randi_range(min_val, max_val)

static func get_random_float(min_val: float, max_val: float) -> float:
	return _rng.randf_range(min_val, max_val)

static func get_new_uuid() -> String:
	var bytes = PackedByteArray()
	bytes.resize(16)
	for i in range(bytes.size()):
		bytes[i] = _rng.randi_range(0, 255)
	return bytes.hex_encode()

static func get_random_string(num_chars: int) -> String:
	var s = ""
	for i in range(num_chars):
		s += char(_rng.randi_range(97, 122))
	return s

static func velocity_from_direction(direction: Vector2, speed: float) -> Vector2:
	if direction == Vector2.ZERO or speed == 0.0:
		return Vector2.ZERO
	return direction.normalized() * speed

static func accelerate_velocity(current: Vector2, direction: Vector2, speed: float, accel: float, delta: float) -> Vector2:
	var target := velocity_from_direction(direction, speed)
	return current.move_toward(target, accel * delta)

static func decelerate_velocity(current: Vector2, friction: float, delta: float) -> Vector2:
	return current.move_toward(Vector2.ZERO, friction * delta)

static func advance_position(position: Vector2, direction: Vector2, speed: float, delta: float) -> Vector2:
	return position + velocity_from_direction(direction, speed) * delta

static func clamp_to_rect(position: Vector2, rect: Rect2, half_extent: Vector2 = Vector2.ZERO) -> Vector2:
	var valid_rect = rect.abs()
	var min_x = valid_rect.position.x + half_extent.x
	var max_x = valid_rect.position.x + valid_rect.size.x - half_extent.x
	var min_y = valid_rect.position.y + half_extent.y
	var max_y = valid_rect.position.y + valid_rect.size.y - half_extent.y
	return Vector2(
		clamp(position.x, min_x, max_x),
		clamp(position.y, min_y, max_y)
	)

static func roll_damage(base_damage: float, crit_rate: float, crit_multiplier: float, rng: RandomNumberGenerator = null) -> Dictionary:
	var roller := rng if rng else _rng
	if roller == null:
		_rng = RandomNumberGenerator.new()
		roller = _rng
	var is_crit = roller.randf() < max(crit_rate, 0.0)
	var final_damage := base_damage
	if is_crit:
		final_damage = round(base_damage * crit_multiplier)
	return {
		"damage": final_damage,
		"is_crit": is_crit,
	}

static func tick_cooldown(current: float, delta: float) -> float:
	return max(current - delta, 0.0)

static func distance(a: Vector2, b: Vector2) -> float:
	return a.distance_to(b)
