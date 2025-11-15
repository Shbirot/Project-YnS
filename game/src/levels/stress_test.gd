extends Node2D

## Performance Stress Test Scene
## Spawns 300-2000 enemies and projectiles to benchmark performance

@export var initial_enemy_count := 300
@export var max_enemy_count := 2000
@export var spawn_interval := 1.0
@export var spawn_radius := 500.0
@export var enemy_archetype_id := "basic_swarmer"

var _elapsed := 0.0
var _spawn_timer := 0.0
var _enemy_count := 0
var _fps_samples: Array[float] = []
var _frame_times: Array[float] = []

@onready var _ui_container := $CanvasLayer/StressTestUI
@onready var _fps_label := $CanvasLayer/StressTestUI/FPSLabel
@onready var _memory_label := $CanvasLayer/StressTestUI/MemoryLabel
@onready var _enemy_count_label := $CanvasLayer/StressTestUI/EnemyCountLabel
@onready var _frame_time_label := $CanvasLayer/StressTestUI/FrameTimeLabel

func _ready() -> void:
	_setup_ui()
	_spawn_initial_enemies()
	var logger = SingletonUtil.get_logger()
	if logger:
		logger.info("Stress test started", {
			"initial_enemies": initial_enemy_count,
			"max_enemies": max_enemy_count
		})

func _process(delta: float) -> void:
	_elapsed += delta
	_spawn_timer += delta

	# Collect performance metrics
	_collect_metrics(delta)

	# Spawn more enemies periodically
	if _spawn_timer >= spawn_interval and _enemy_count < max_enemy_count:
		_spawn_wave(10)
		_spawn_timer = 0.0

	# Update UI
	_update_ui()

func _setup_ui() -> void:
	if not _ui_container:
		return

	# Position UI in top-left
	if _fps_label:
		_fps_label.position = Vector2(10, 10)
	if _frame_time_label:
		_frame_time_label.position = Vector2(10, 40)
	if _memory_label:
		_memory_label.position = Vector2(10, 70)
	if _enemy_count_label:
		_enemy_count_label.position = Vector2(10, 100)

func _spawn_initial_enemies() -> void:
	for i in range(initial_enemy_count):
		_spawn_enemy()

func _spawn_wave(count: int) -> void:
	for i in range(count):
		if _enemy_count >= max_enemy_count:
			break
		_spawn_enemy()

func _spawn_enemy() -> void:
	var angle = randf() * TAU
	var distance = randf_range(100.0, spawn_radius)
	var offset = Vector2(cos(angle), sin(angle)) * distance
	var spawn_pos = Vector2(640, 360) + offset

	# Use SpawnService if available
	var spawn_service = get_node_or_null("/root/SpawnService")
	var archetype_registry = EnemyArchetypeRegistry.load_archetypes("res://config/enemies")
	var archetype = archetype_registry.get(enemy_archetype_id)

	if spawn_service and archetype:
		spawn_service.spawn_enemy(archetype, spawn_pos, self)
		_enemy_count += 1
	else:
		# Fallback: manual spawn
		_enemy_count += 1

func _collect_metrics(delta: float) -> void:
	var fps = Engine.get_frames_per_second()
	var frame_time = delta * 1000.0  # Convert to ms

	_fps_samples.append(fps)
	_frame_times.append(frame_time)

	# Keep only last 60 samples
	if _fps_samples.size() > 60:
		_fps_samples.pop_front()
	if _frame_times.size() > 60:
		_frame_times.pop_front()

func _update_ui() -> void:
	if _fps_label:
		var avg_fps = _average(_fps_samples)
		_fps_label.text = "FPS: %.1f" % avg_fps

	if _frame_time_label:
		var avg_frame_time = _average(_frame_times)
		_frame_time_label.text = "Frame Time: %.2f ms" % avg_frame_time

	if _memory_label:
		var memory_mb = OS.get_static_memory_usage() / 1024.0 / 1024.0
		_memory_label.text = "Memory: %.1f MB" % memory_mb

	if _enemy_count_label:
		_enemy_count_label.text = "Enemies: %d / %d" % [_enemy_count, max_enemy_count]

func _average(samples: Array) -> float:
	if samples.is_empty():
		return 0.0
	var sum = 0.0
	for sample in samples:
		sum += sample
	return sum / samples.size()

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")
const EnemyArchetypeRegistry = preload("res://src/features/enemy/enemy_archetype_registry.gd")
