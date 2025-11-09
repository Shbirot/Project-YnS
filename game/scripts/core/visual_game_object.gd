extends CharacterBody2D
class_name VisualGameObject

const Log = preload("res://scripts/utils/log_helper.gd")

## Base node for every visible entity in the world (characters, pickups, props, etc.).
## Provides identity, enable/disable lifecycle hooks, and sprite management.

@export var object_id : String = ""
@export var display_name : String = "Object"
@export var sprite_texture : Texture2D
@export var is_enabled := true

## Enable this to use AnimatedSprite2D instead of static Sprite2D
@export var use_animated_sprite := false
## SpriteFrames resource for AnimatedSprite2D (required if use_animated_sprite is true)
@export var sprite_frames : SpriteFrames

## Main sprite node - can be either Sprite2D or AnimatedSprite2D
@onready var sprite : Node2D = _find_or_create_sprite()
## Reference to static sprite (if using Sprite2D)
var static_sprite : Sprite2D
## Reference to animated sprite (if using AnimatedSprite2D)
var animated_sprite : AnimatedSprite2D

func _ready() -> void:
	_update_enabled_state(is_enabled)
	if sprite_texture:
		_apply_texture(sprite_texture)
	Log.debug("VisualGameObject ready: %s" % _log_name())

func _exit_tree() -> void:
	Log.debug("VisualGameObject exiting: %s" % _log_name())

func _find_or_create_sprite() -> Node2D:
	# Check for existing AnimatedSprite2D first
	var anim_sprite := get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if anim_sprite:
		use_animated_sprite = true
		animated_sprite = anim_sprite
		return anim_sprite

	# Fall back to Sprite2D
	var static_spr := get_node_or_null("Sprite2D") as Sprite2D
	if static_spr:
		static_sprite = static_spr
		return static_spr

	# Create new sprite based on export setting
	if use_animated_sprite:
		animated_sprite = AnimatedSprite2D.new()
		animated_sprite.name = "AnimatedSprite2D"
		if sprite_frames:
			animated_sprite.sprite_frames = sprite_frames
		add_child(animated_sprite)
		return animated_sprite
	else:
		static_sprite = Sprite2D.new()
		static_sprite.name = "Sprite2D"
		add_child(static_sprite)
		return static_sprite

func _apply_texture(texture: Texture2D) -> void:
	if static_sprite:
		static_sprite.texture = texture
	elif animated_sprite:
		# AnimatedSprite2D uses sprite_frames, not direct texture
		# If we're trying to set a static texture on an animated sprite, warn
		Log.warn("Cannot apply static texture to AnimatedSprite2D for %s" % _log_name())

func set_enabled(value: bool) -> void:
	is_enabled = value
	_update_enabled_state(value)
	Log.debug("VisualGameObject %s enabled=%s" % [_log_name(), value])

func _update_enabled_state(value: bool) -> void:
	visible = value
	set_process(value)
	set_physics_process(value)

func set_sprite_from_path(path: String) -> void:
	var tex = load(path)
	if tex is Texture2D:
		sprite_texture = tex
		_apply_texture(tex)
	else:
		Log.warn("Failed loading texture for %s from %s" % [_log_name(), path])

func _log_name() -> String:
	var name_candidate = display_name
	if name_candidate == "" or name_candidate == null:
		name_candidate = name
	return name_candidate if name_candidate != "" else str(get_instance_id())

## Play an animation on AnimatedSprite2D (only works if use_animated_sprite is true)
func play_animation(anim_name: String, force_restart := false) -> void:
	if not animated_sprite:
		return

	if force_restart or animated_sprite.animation != anim_name:
		animated_sprite.play(anim_name)

## Stop the current animation
func stop_animation() -> void:
	if animated_sprite:
		animated_sprite.stop()

## Get the current animation name (returns empty string if not using AnimatedSprite2D)
func get_current_animation() -> String:
	if animated_sprite:
		return animated_sprite.animation
	return ""

## Check if an animation is currently playing
func is_playing_animation() -> bool:
	if animated_sprite:
		return animated_sprite.is_playing()
	return false
