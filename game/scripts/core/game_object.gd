extends Node2D
class_name GameObject

const Log = preload("res://scripts/utils/log_helper.gd")

## Property-based game object system
## Allows flexible combinations of behaviors through orthogonal properties
## instead of rigid inheritance hierarchies

## Enums defining object behavior

enum PhysicsMode {
	NONE,       # No physics processing (UI, decorations)
	STATIC,     # Has collision but never moves (walls, obstacles)
	KINEMATIC,  # Scripted movement (player, enemies)
	DYNAMIC     # Physics-driven movement (rolling objects)
}

enum CollisionMode {
	NONE,      # No collision (background decorations)
	PHYSICAL,  # Blocks movement (walls, obstacles)
	SENSOR,    # Detects overlap only (pickups, triggers)
	MIXED      # Both physical body + sensor area
}

enum MovementMode {
	STATIC,    # Never moves
	VELOCITY,  # Direct velocity control (most characters)
	PATH,      # Follows a path (clouds, moving platforms)
	PHYSICS,   # Governed by physics forces (rolling objects)
	AI         # AI-controlled movement
}

enum InteractionType {
	NONE,         # No interaction
	COLLECTIBLE,  # Auto-collect on overlap (coins, powerups)
	TRIGGERABLE,  # One-time activation (chests, switches)
	CONVERSABLE,  # Dialogue/menu interaction (NPCs, shops)
	CUSTOM        # Complex custom logic
}

enum RenderTier {
	CRITICAL,    # Always render (player, enemies)
	IMPORTANT,   # Render if on-screen (projectiles, effects)
	DECORATIVE   # Can skip if performance drops (particles, clouds)
}

## Core properties
@export var object_id: String = ""
@export var display_name: String = "Object"
@export var is_enabled: bool = true

## Behavior properties
var physics_mode: PhysicsMode = PhysicsMode.NONE
var collision_mode: CollisionMode = CollisionMode.NONE
var movement_mode: MovementMode = MovementMode.STATIC
var interaction_type: InteractionType = InteractionType.NONE
var render_tier: RenderTier = RenderTier.IMPORTANT

## Components (lazy-created)
var sprite: Sprite2D = null
var collision_shape: CollisionShape2D = null
var interaction_area: Area2D = null

## Stats dictionary for flexible data storage
var stats: Dictionary = {}

## Pooling support
var _is_pooled: bool = false
var _pool_id: String = ""

func _ready() -> void:
	_setup_components()
	_update_enabled_state(is_enabled)
	_on_spawn()
	Log.debug("GameObject ready: %s (physics=%s, collision=%s)" % [_log_name(), PhysicsMode.keys()[physics_mode], CollisionMode.keys()[collision_mode]])

## Lifecycle hooks (override in subclasses)
func _on_spawn() -> void:
	pass

func _on_despawn() -> void:
	pass

func _on_enable() -> void:
	pass

func _on_disable() -> void:
	pass

## Pooling interface
func reset() -> void:
	# Clear state for reuse
	stats.clear()
	global_position = Vector2.ZERO
	rotation = 0.0
	scale = Vector2.ONE
	is_enabled = true

func activate() -> void:
	_is_pooled = false
	set_enabled(true)
	_on_spawn()

func deactivate() -> void:
	_is_pooled = true
	set_enabled(false)
	_on_despawn()

## Component management
func _setup_components() -> void:
	# Sprite is created on demand
	if has_node("Sprite2D"):
		sprite = get_node("Sprite2D")

	# Collision shape is created based on collision_mode
	if collision_mode != CollisionMode.NONE:
		_ensure_collision_shape()

	# Interaction area is created for interactable objects
	if interaction_type != InteractionType.NONE:
		_ensure_interaction_area()

func _ensure_sprite() -> Sprite2D:
	if sprite:
		return sprite

	sprite = get_node_or_null("Sprite2D")
	if sprite:
		return sprite

	sprite = Sprite2D.new()
	sprite.name = "Sprite2D"
	add_child(sprite)
	return sprite

func _ensure_collision_shape() -> CollisionShape2D:
	if collision_shape:
		return collision_shape

	collision_shape = get_node_or_null("CollisionShape2D")
	if collision_shape:
		return collision_shape

	collision_shape = CollisionShape2D.new()
	collision_shape.name = "CollisionShape2D"
	add_child(collision_shape)
	return collision_shape

func _ensure_interaction_area() -> Area2D:
	if interaction_area:
		return interaction_area

	interaction_area = get_node_or_null("InteractionArea")
	if interaction_area:
		return interaction_area

	interaction_area = Area2D.new()
	interaction_area.name = "InteractionArea"
	add_child(interaction_area)

	# Add collision shape to area
	var area_shape = CollisionShape2D.new()
	area_shape.name = "CollisionShape2D"
	interaction_area.add_child(area_shape)

	return interaction_area

## Enable/disable management
func set_enabled(value: bool) -> void:
	is_enabled = value
	_update_enabled_state(value)
	if value:
		_on_enable()
	else:
		_on_disable()
	Log.debug("GameObject %s enabled=%s" % [_log_name(), value])

func _update_enabled_state(value: bool) -> void:
	visible = value
	set_process(value)
	set_physics_process(value)

## Sprite management
func set_sprite_texture(texture: Texture2D) -> void:
	var spr = _ensure_sprite()
	spr.texture = texture

func set_sprite_from_path(path: String) -> void:
	var tex = load(path)
	if tex is Texture2D:
		set_sprite_texture(tex)
	else:
		Log.warn("Failed loading texture for %s from %s" % [_log_name(), path])

func get_sprite() -> Sprite2D:
	return _ensure_sprite()

## Utility
func _log_name() -> String:
	if display_name != "" and display_name != null:
		return display_name
	if object_id != "" and object_id != null:
		return object_id
	if name != "" and name != null:
		return name
	return str(get_instance_id())

func get_display_name() -> String:
	return _log_name()

## Pooling helpers
func is_pooled() -> bool:
	return _is_pooled

func set_pool_id(id: String) -> void:
	_pool_id = id

func get_pool_id() -> String:
	return _pool_id
