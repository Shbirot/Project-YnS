extends Node

## Unified input pipeline for movement input
## Reduces redundant Input API calls and normalizes input logic

const DEBUG_INPUT_DRIVER = false  # Set to true to enable debug logging

var _override_direction := Vector2.ZERO
var _override_active := false

func _ready() -> void:
	if DEBUG_INPUT_DRIVER:
		print("[InputDriver] READY - Autoload initialized")
	set_physics_process(true)

func _input(event: InputEvent) -> void:
	if not DEBUG_INPUT_DRIVER:
		return
	# Test if _input is even being called
	if event is InputEventKey and event.pressed:
		print("[InputDriver] _input received key: ", event.as_text())
		# Test if action mapping works
		print("[InputDriver] Action checks - move_right: ", Input.is_action_pressed("move_right"),
			" move_left: ", Input.is_action_pressed("move_left"),
			" move_up: ", Input.is_action_pressed("move_up"),
			" move_down: ", Input.is_action_pressed("move_down"))

# Cached action strengths for current frame
var _cached_right := 0.0
var _cached_left := 0.0
var _cached_down := 0.0
var _cached_up := 0.0
var _cached_ui_right := 0.0
var _cached_ui_left := 0.0
var _cached_ui_down := 0.0
var _cached_ui_up := 0.0
var _cache_frame := -1

func _physics_process(_delta: float) -> void:
	# Cache is updated on-demand in get_direction(), not here
	pass

func get_direction() -> Vector2:
	# Use override if active
	if _override_active and _override_direction.length_squared() > 0.0:
		if OS.has_environment("NF_DEBUG_INPUT") and OS.get_environment("NF_DEBUG_INPUT") == "1":
			DebugUtils.debug_log("Input override active", {"dir": _override_direction})
		return _override_direction.normalized()

	# Cache action strengths for this frame
	_update_cache()

	# Build input vector from cached values
	var vector := Vector2(
		_cached_right - _cached_left,
		_cached_down - _cached_up
	)

	if DEBUG_INPUT_DRIVER and (_cached_right > 0 or _cached_left > 0 or _cached_down > 0 or _cached_up > 0):
		print("[InputDriver] Cached values - R:", _cached_right, " L:", _cached_left, " D:", _cached_down, " U:", _cached_up, " Vector:", vector)

	# Fallback to ui_ actions if move_ actions are zero
	if vector.length_squared() == 0.0:
		vector = Vector2(
			_cached_ui_right - _cached_ui_left,
			_cached_ui_down - _cached_ui_up
		)

	# Normalize and return
	if vector.length_squared() > 0.0:
		if DEBUG_INPUT_DRIVER:
			print("[InputDriver] Returning normalized vector: ", vector.normalized())
		if OS.has_environment("NF_DEBUG_INPUT") and OS.get_environment("NF_DEBUG_INPUT") == "1":
			DebugUtils.debug_log("Input vector", {"dir": vector})
		return vector.normalized()

	return Vector2.ZERO

func set_override(vec: Vector2) -> void:
	_override_direction = vec
	_override_active = true
	if OS.has_environment("NF_DEBUG_INPUT") and OS.get_environment("NF_DEBUG_INPUT") == "1":
		DebugUtils.debug_log("Input override set", {"dir": vec})

func clear_override() -> void:
	_override_direction = Vector2.ZERO
	_override_active = false
	if OS.has_environment("NF_DEBUG_INPUT") and OS.get_environment("NF_DEBUG_INPUT") == "1":
		DebugUtils.debug_log("Input override cleared", {})

func is_override_active() -> bool:
	return _override_active

func _update_cache() -> void:
	var current_frame = Engine.get_physics_frames()
	if _cache_frame == current_frame:
		return

	_cache_frame = current_frame
	_cached_right = Input.get_action_strength("move_right")
	_cached_left = Input.get_action_strength("move_left")
	_cached_down = Input.get_action_strength("move_down")
	_cached_up = Input.get_action_strength("move_up")
	_cached_ui_right = Input.get_action_strength("ui_right")
	_cached_ui_left = Input.get_action_strength("ui_left")
	_cached_ui_down = Input.get_action_strength("ui_down")
	_cached_ui_up = Input.get_action_strength("ui_up")
