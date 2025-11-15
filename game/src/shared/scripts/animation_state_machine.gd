extends Resource
class_name AnimationStateMachine

## Table-driven animation state machine with cached lookups
## Avoids string building and has_animation() calls per frame

@export var idle_animation := "idle"
@export var breathing_animation := "breathing"
@export var movement_prefix := "run_"
@export var movement_fallback := "walk"
@export var breathing_threshold := 5.0

# Cached animation map: direction -> animation name
var _animation_cache: Dictionary = {}
var _cache_built := false

func build_cache(sprite_frames: SpriteFrames) -> void:
	if _cache_built:
		return

	_animation_cache.clear()

	# Build direction->animation map
	var directions = ["up", "down", "left", "right"]
	for dir in directions:
		var anim_name = "%s%s" % [movement_prefix, dir]
		if sprite_frames.has_animation(anim_name):
			_animation_cache[dir] = anim_name
		elif sprite_frames.has_animation(movement_fallback):
			_animation_cache[dir] = movement_fallback
		else:
			_animation_cache[dir] = idle_animation

	_cache_built = true

func compute(input_vector: Vector2, velocity: Vector2, sprite_frames: SpriteFrames) -> String:
	# Build cache on first call
	if not _cache_built:
		build_cache(sprite_frames)
	var is_moving = input_vector.length_squared() > 0.0

	if is_moving:
		var direction = _direction_from_vector(input_vector)
		# Use cached animation name instead of building string
		return _animation_cache.get(direction, idle_animation)
	else:
		# Check if breathing animation should play
		if velocity.length() > breathing_threshold and sprite_frames.has_animation(breathing_animation):
			return breathing_animation
		else:
			return idle_animation

func _direction_from_vector(dir: Vector2) -> String:
	if abs(dir.x) > abs(dir.y):
		return "right" if dir.x > 0.0 else "left"
	else:
		return "down" if dir.y > 0.0 else "up"
