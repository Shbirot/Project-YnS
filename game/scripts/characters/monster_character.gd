extends Character

class_name MonsterCharacter

const MovementSystem = preload("res://scripts/systems/movement_system.gd")
const CombatSystem = preload("res://scripts/systems/combat_system.gd")
const WorldBounds = preload("res://scripts/systems/world_bounds.gd")
const HALF_EXTENT := Vector2(20, 20)

@export var contact_damage := 10
@export var damage_interval := 0.8
var _damage_cooldown := 0.0
var _target : Node2D

func set_target(target: Node2D) -> void:
	_target = target

func initialize(target: Node2D) -> void:
	set_target(target)
	_log_collision_geometry()

func _log_collision_geometry() -> void:
	var shape = get_node_or_null("CollisionShape2D")
	if shape and shape.shape:
		var shape_type = shape.shape.get_class()
		var shape_details = ""
		if shape.shape is CircleShape2D:
			shape_details = "radius=%.1f" % shape.shape.radius
		elif shape.shape is RectangleShape2D:
			shape_details = "size=%s (half_diagonal=%.1f)" % [shape.shape.size, shape.shape.size.length() / 2.0]
		elif shape.shape is CapsuleShape2D:
			shape_details = "radius=%.1f, height=%.1f" % [shape.shape.radius, shape.shape.height]
		Log.info("MONSTER COLLISION: %s type=%s, %s, position=%s, collision_layer=%d, collision_mask=%d" % [display_name, shape_type, shape_details, global_position, collision_layer, collision_mask])
	else:
		Log.warn("MONSTER COLLISION: %s has NO collision shape!" % display_name)

func _physics_process(delta: float) -> void:
	if not is_enabled:
		return
	if not is_instance_valid(_target):
		velocity = Vector2.ZERO
		return
	MovementSystem.seek_target(self, _target, move_speed)
	_damage_cooldown = CombatSystem.tick_cooldown(_damage_cooldown, delta)
	var distance = global_position.distance_to(_target.global_position)

	# Calculate collision extents for accurate contact detection
	var my_shape = get_node_or_null("CollisionShape2D")
	var target_shape = _target.get_node_or_null("CollisionShape2D")
	var my_extent = 0.0
	var target_extent = 0.0

	if my_shape and my_shape.shape:
		if my_shape.shape is CircleShape2D:
			my_extent = my_shape.shape.radius
		elif my_shape.shape is RectangleShape2D:
			# RectangleShape2D uses 'size' in Godot 4.x (was 'extents' in Godot 3.x)
			# Approximate as half diagonal for distance calc
			my_extent = my_shape.shape.size.length() / 2.0

	if target_shape and target_shape.shape:
		if target_shape.shape is CircleShape2D:
			target_extent = target_shape.shape.radius
		elif target_shape.shape is RectangleShape2D:
			target_extent = target_shape.shape.size.length() / 2.0

	var edge_distance = distance - my_extent - target_extent

	# Log when getting close
	if distance < 50:
		Log.info("DISTANCE CHECK: %s->target | center_dist=%.1f, my_extent=%.1f, target_extent=%.1f, edge_dist=%.1f, cooldown=%.2f" % [
			display_name, distance, my_extent, target_extent, edge_distance, _damage_cooldown
		])

	# Use edge distance (negative = touching/overlapping) instead of center distance
	if edge_distance < 0:
		var cooldown_ready = _damage_cooldown <= 0.0
		Log.info("CONTACT ATTEMPT: %s edge_dist=%.1f < 0 (TOUCHING), cooldown_ready=%s" % [display_name, edge_distance, cooldown_ready])
		var applied = CombatSystem.try_contact_damage(self, _target, contact_damage, cooldown_ready)
		if applied:
			Log.info("CONTACT DAMAGE APPLIED: %s dealt %d damage to %s" % [display_name, contact_damage, _target.get_display_name() if _target.has_method("get_display_name") else "target"])
			_damage_cooldown = damage_interval
		else:
			Log.info("CONTACT DAMAGE BLOCKED: %s cooldown not ready (%.2fs remaining)" % [display_name, _damage_cooldown])
	WorldBounds.clamp_to_world(self, HALF_EXTENT)
