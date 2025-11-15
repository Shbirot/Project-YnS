extends Node
class_name AutoplayAgent

signal simulation_finished(metrics: Dictionary)

@export var duration := 20.0
@export var movement_sequence: Array = []
@export var randomize_after_sequence := true
@export var random_turn_interval := 1.5
@export var seed := 0
@export var log_interval := 5.0

var _hero: Node
var _event_bus: Node
var _elapsed := 0.0
var _segment_time := 0.0
var _sequence_index := 0
var _random_time := 0.0
var _rng := RandomNumberGenerator.new()
var _metrics := {
	"enemies_defeated": 0,
	"xp_collected": 0,
	"level_reached": 1,
	"duration": 0.0
}
var _next_log := 0.0

func set_hero_reference(hero: Node) -> void:
	_hero = hero

func setup(config: Dictionary) -> void:
	duration = float(config.get("duration", duration))
	movement_sequence = config.get("movement_sequence", movement_sequence)
	randomize_after_sequence = config.get("randomize_after_sequence", randomize_after_sequence)
	random_turn_interval = float(config.get("random_turn_interval", random_turn_interval))
	seed = int(config.get("seed", seed))
	if seed != 0:
		_rng.seed = seed
	else:
		_rng.randomize()

func _ready() -> void:
	_event_bus = get_node_or_null("/root/EventBus")
	if _event_bus:
		if not _event_bus.is_connected("enemy_died", Callable(self, "_on_enemy_died")):
			_event_bus.connect("enemy_died", Callable(self, "_on_enemy_died"))
		if not _event_bus.is_connected("xp_collected", Callable(self, "_on_xp_collected")):
			_event_bus.connect("xp_collected", Callable(self, "_on_xp_collected"))
		if not _event_bus.is_connected("level_up", Callable(self, "_on_level_up")):
			_event_bus.connect("level_up", Callable(self, "_on_level_up"))
	if _hero == null:
		await get_tree().process_frame
		_hero = get_tree().get_first_node_in_group("hero")
	if _hero == null:
		push_error("[autoplay] Hero not found; simulation cannot run.")
		return
	_apply_sequence_direction()
	_next_log = log_interval

func _physics_process(delta: float) -> void:
	if _hero == null:
		return
	_elapsed += delta
	_metrics["duration"] = _elapsed

	if _elapsed >= duration:
		_finish_simulation()
		return

	_segment_time += delta
	_random_time += delta

	if _sequence_index < movement_sequence.size():
		var segment = movement_sequence[_sequence_index]
		var target_seconds := float(segment.get("seconds", 1.0))
		if _segment_time >= target_seconds:
			_sequence_index += 1
			_segment_time = 0.0
			if _sequence_index < movement_sequence.size():
				_apply_sequence_direction()
			elif randomize_after_sequence:
				_random_time = random_turn_interval
	else:
		if randomize_after_sequence and _random_time >= random_turn_interval:
			_random_time = 0.0
			_apply_random_direction()

	if _elapsed >= _next_log:
		_log_status()
		_next_log += log_interval

func _finish_simulation() -> void:
	if _hero and _hero.has_method("clear_input_override"):
		_hero.clear_input_override()
	_metrics["duration"] = _elapsed
	emit_signal("simulation_finished", _metrics)
	queue_free()

func _apply_sequence_direction() -> void:
	if _sequence_index >= movement_sequence.size():
		return
	var entry = movement_sequence[_sequence_index]
	var dir := _direction_from_entry(entry)
	_set_hero_direction(dir)

func _apply_random_direction() -> void:
	var angle := _rng.randf_range(0, TAU)
	var dir = Vector2.RIGHT.rotated(angle)
	_set_hero_direction(dir)

func _direction_from_entry(entry: Dictionary) -> Vector2:
	if entry.has("direction") and entry.direction is Array and entry.direction.size() == 2:
		var arr: Array = entry.direction
		return Vector2(float(arr[0]), float(arr[1]))
	if entry.has("angle_deg"):
		return Vector2.RIGHT.rotated(deg_to_rad(float(entry.angle_deg)))
	return Vector2.RIGHT

func _set_hero_direction(direction: Vector2) -> void:
	if _hero == null:
		return
	if not _hero.has_method("set_input_override"):
		push_warning("[autoplay] Hero lacks set_input_override; cannot drive movement.")
		return
	_hero.set_input_override(direction)

func _on_enemy_died(_enemy: Node, _source: Node) -> void:
	_metrics["enemies_defeated"] += 1

func _on_xp_collected(amount: int, _position: Vector2) -> void:
	_metrics["xp_collected"] += amount

func _on_level_up(level: int) -> void:
	_metrics["level_reached"] = max(_metrics["level_reached"], level)

func _log_status() -> void:
	print("[autoplay] t=%.1f  xp=%d  enemies=%d  level=%d" % [
		_elapsed,
		_metrics["xp_collected"],
		_metrics["enemies_defeated"],
		_metrics["level_reached"]
	])
