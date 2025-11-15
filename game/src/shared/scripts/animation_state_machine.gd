extends Resource
class_name AnimationStateMachine

## Table-driven animation state machine
## Replaces branching if-else logic with simple state lookup

@export var idle_animation := "idle"
@export var breathing_animation := "breathing"
@export var movement_prefix := "run_"
@export var movement_fallback := "walk"
@export var breathing_threshold := 5.0

func compute(input_vector: Vector2, velocity: Vector2, sprite_frames: SpriteFrames) -> String:
	var is_moving = input_vector.length_squared() > 0.0

	if is_moving:
		var direction = _direction_from_vector(input_vector)
		var anim_name = "%s%s" % [movement_prefix, direction]

		if sprite_frames.has_animation(anim_name):
			return anim_name
		elif sprite_frames.has_animation(movement_fallback):
			return movement_fallback
		else:
			return idle_animation
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
