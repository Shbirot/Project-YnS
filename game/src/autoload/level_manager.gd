extends Node

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")

@export var starting_level = 1
@export var xp_curve = PackedFloat32Array([30, 70, 130, 200, 300])

var current_level = 1
var current_xp = 0
var _event_bus: Node

signal xp_changed(current_xp, required_xp, level)
signal leveled_up(new_level)

func _ready() -> void:
	_apply_env_overrides()
	current_level = starting_level
	current_xp = 0
	_bind_event_bus()
	emit_state()

func add_xp(amount: int) -> void:
	current_xp += amount
	while current_xp >= _required_for_level(current_level):
		current_xp -= _required_for_level(current_level)
		current_level += 1
		leveled_up.emit(current_level)
		if _event_bus:
			_event_bus.emit_safe("level_up", [current_level])
	emit_state()

func emit_state() -> void:
	xp_changed.emit(current_xp, _required_for_level(current_level), current_level)

func _required_for_level(level: int) -> int:
	var index = clamp(level, 1, xp_curve.size())
	return int(xp_curve[index - 1])

func _bind_event_bus() -> void:
	_event_bus = SingletonUtil.get_event_bus()
	if _event_bus:
		if not _event_bus.is_connected("xp_collected", Callable(self, "_on_xp_collected")):
			_event_bus.connect("xp_collected", Callable(self, "_on_xp_collected"))

func _on_xp_collected(amount: int, _position: Vector2) -> void:
	add_xp(amount)

func _apply_env_overrides() -> void:
	var cfg = SingletonUtil.get_game_config()
	starting_level = cfg.get_env_value("NF_LEVEL_STARTING_LEVEL", starting_level)
