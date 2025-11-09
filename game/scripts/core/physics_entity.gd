extends CharacterBody2D
class_name PhysicsEntity

const Log = preload("res://scripts/utils/log_helper.gd")

## Physics-enabled game object
## Uses CharacterBody2D as base for kinematic movement
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

## Core properties (same as GameObject)
@export var object_id: String = ""
@export var display_name: String = "PhysicsEntity"
@export var is_enabled: bool = true
@export var move_speed: float = 200.0

## Behavior properties (defaults for physics entities)
var physics_mode: PhysicsMode = PhysicsMode.KINEMATIC
var collision_mode: CollisionMode = CollisionMode.PHYSICAL
var movement_mode: MovementMode = MovementMode.VELOCITY
var interaction_type: InteractionType = InteractionType.NONE
var render_tier: RenderTier = RenderTier.IMPORTANT

## Components
var sprite: Sprite2D = null
var animated_sprite: AnimatedSprite2D = null
var collision_shape: CollisionShape2D = null
var interaction_area: Area2D = null

## Animation properties
@export var use_animated_sprite := false
@export var sprite_frames : SpriteFrames

## Stats dictionary
var stats: Dictionary = {}

## Pooling support
var _is_pooled: bool = false
var _pool_id: String = ""

func _ready() -> void:
	_setup_components()
	_update_enabled_state(is_enabled)
	_on_spawn()
	Log.debug("PhysicsEntity ready: %s (physics=%s, collision=%s)" % [_log_name(), PhysicsMode.keys()[physics_mode], CollisionMode.keys()[collision_mode]])

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
	velocity = Vector2.ZERO
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
	if has_node("AnimatedSprite2D"):
		animated_sprite = get_node("AnimatedSprite2D")
		use_animated_sprite = true
	elif has_node("Sprite2D"):
		sprite = get_node("Sprite2D")

	if collision_mode != CollisionMode.NONE:
		_ensure_collision_shape()

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
	Log.debug("PhysicsEntity %s enabled=%s" % [_log_name(), value])

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

## Animation support for Character classes
func play_animation(anim_name: String, force_restart := false) -> void:
	if not animated_sprite:
		return
	if force_restart or animated_sprite.animation != anim_name:
		animated_sprite.play(anim_name)

func stop_animation() -> void:
	if animated_sprite:
		animated_sprite.stop()

func get_current_animation() -> String:
	if animated_sprite:
		return animated_sprite.animation
	return ""

func is_playing_animation() -> bool:
	if animated_sprite:
		return animated_sprite.is_playing()
	return false
