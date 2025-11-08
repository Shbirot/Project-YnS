extends Node2D
class_name StaticEntity

const Log = preload("res://scripts/utils/log_helper.gd")

## Static game object (never moves)
## Uses Node2D as base for minimal overhead
## Inherits GameObject's property system

## Import enums from GameObject
enum PhysicsMode {
	NONE,
	STATIC,
	KINEMATIC,
	DYNAMIC
}

enum CollisionMode {
	NONE,
	PHYSICAL,
	SENSOR,
	MIXED
}

enum MovementMode {
	STATIC,
	VELOCITY,
	PATH,
	PHYSICS,
	AI
}

enum InteractionType {
	NONE,
	COLLECTIBLE,
	TRIGGERABLE,
	CONVERSABLE,
	CUSTOM
}

enum RenderTier {
	CRITICAL,
	IMPORTANT,
	DECORATIVE
}

## Core properties
@export var object_id: String = ""
@export var display_name: String = "StaticEntity"
@export var is_enabled: bool = true

## Behavior properties (defaults for static entities)
var physics_mode: PhysicsMode = PhysicsMode.STATIC
var collision_mode: CollisionMode = CollisionMode.NONE
var movement_mode: MovementMode = MovementMode.STATIC
var interaction_type: InteractionType = InteractionType.NONE
var render_tier: RenderTier = RenderTier.IMPORTANT

## Components
var sprite: Sprite2D = null
var static_body: StaticBody2D = null
var collision_shape: CollisionShape2D = null
var interaction_area: Area2D = null

## Stats dictionary
var stats: Dictionary = {}

## Pooling support
var _is_pooled: bool = false
var _pool_id: String = ""

func _ready() -> void:
	_setup_components()
	_update_enabled_state(is_enabled)
	_on_spawn()
	Log.debug("StaticEntity ready: %s (collision=%s, interaction=%s)" % [_log_name(), CollisionMode.keys()[collision_mode], InteractionType.keys()[interaction_type]])

## Lifecycle hooks
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
	if has_node("Sprite2D"):
		sprite = get_node("Sprite2D")

	# Create StaticBody2D if collision is PHYSICAL
	if collision_mode == CollisionMode.PHYSICAL or collision_mode == CollisionMode.MIXED:
		_ensure_static_body()

	# Create interaction area if needed
	if interaction_type != InteractionType.NONE or collision_mode == CollisionMode.SENSOR or collision_mode == CollisionMode.MIXED:
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

func _ensure_static_body() -> StaticBody2D:
	if static_body:
		return static_body

	static_body = get_node_or_null("StaticBody2D")
	if static_body:
		collision_shape = static_body.get_node_or_null("CollisionShape2D")
		return static_body

	static_body = StaticBody2D.new()
	static_body.name = "StaticBody2D"
	add_child(static_body)

	collision_shape = CollisionShape2D.new()
	collision_shape.name = "CollisionShape2D"
	static_body.add_child(collision_shape)

	return static_body

func _ensure_interaction_area() -> Area2D:
	if interaction_area:
		return interaction_area

	interaction_area = get_node_or_null("InteractionArea")
	if interaction_area:
		return interaction_area

	interaction_area = Area2D.new()
	interaction_area.name = "InteractionArea"
	add_child(interaction_area)

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
	Log.debug("StaticEntity %s enabled=%s" % [_log_name(), value])

func _update_enabled_state(value: bool) -> void:
	visible = value
	set_process(value)

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

## Collision management
func get_static_body() -> StaticBody2D:
	return static_body

func get_collision_shape() -> CollisionShape2D:
	return collision_shape

func set_collision_shape_from_sprite() -> void:
	if not sprite or not sprite.texture:
		Log.warn("Cannot create collision from sprite - no texture")
		return

	_ensure_static_body()
	var shape = RectangleShape2D.new()
	var texture_size = sprite.texture.get_size()
	shape.size = texture_size * sprite.scale
	collision_shape.shape = shape

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
