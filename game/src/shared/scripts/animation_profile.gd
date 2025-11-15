extends Resource
class_name AnimationProfile

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")

@export var sprite_frames: SpriteFrames
@export var default_animation = "idle"
@export var animation_speeds: Dictionary = {}
@export var env_prefix = "NF_ANIM_GENERIC"

func instantiate_frames() -> SpriteFrames:
	if sprite_frames == null:
		return null
	var frames: SpriteFrames = sprite_frames.duplicate()
	if frames == null:
		return null
	for anim_name in frames.get_animation_names():
		var anim: String = anim_name
		var base_speed: float = frames.get_animation_speed(anim)
		var configured: float = animation_speeds.get(anim, base_speed)
		frames.set_animation_speed(anim, _resolve_speed(anim, configured))
	return frames

func _resolve_speed(anim: String, base_speed: float) -> float:
	var cfg = SingletonUtil.get_game_config()
	var key = "%s_%s_SPEED" % [env_prefix, anim.to_upper()]
	return cfg.get_env_value(key, base_speed)
