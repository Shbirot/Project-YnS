extends Node

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")

@export var wave_config_path := "res://config/data/waves.json"
@export var spawn_padding := 64.0

var _waves: Array = []
var _spawned_wave_indices: Dictionary = {}
var _elapsed := 0.0
var _event_bus: Node
var _catalog: Node
var _hero: Node2D
var _active_wave_counts: Dictionary = {}
var _wave_lookup: Dictionary = {}

func _ready() -> void:
	_event_bus = SingletonUtil.get_event_bus()
	_catalog = SingletonUtil.get_game_catalog()
	var cfg = SingletonUtil.get_game_config()
	wave_config_path = cfg.get_env_value("NF_WAVE_CONFIG_PATH", wave_config_path)
	spawn_padding = cfg.get_env_value("NF_SPAWN_PADDING", spawn_padding)
	_load_waves()
	if _event_bus:
		if not _event_bus.is_connected("enemy_died", Callable(self, "_on_enemy_died")):
			_event_bus.connect("enemy_died", Callable(self, "_on_enemy_died"))

func _process(delta: float) -> void:
	_elapsed += delta
	_try_spawn()

func _load_waves() -> void:
	var file := FileAccess.open(wave_config_path, FileAccess.READ)
	if file == null:
		push_error("SpawnerController: cannot read %s" % wave_config_path)
		return
	var json := JSON.new()
	var parse_result := json.parse(file.get_as_text())
	if parse_result != OK:
		push_error("SpawnerController: JSON parse error in %s" % wave_config_path)
		return
	var data = json.data
	_waves = data.get("waves", [])
	for i in range(_waves.size()):
		_wave_lookup[i] = _waves[i]

func _try_spawn() -> void:
	_hero = _hero if _hero else get_tree().get_first_node_in_group("hero")
	for i in range(_waves.size()):
		if _spawned_wave_indices.has(i):
			continue
		var wave: Dictionary = _waves[i]
		if _elapsed >= wave.get("time", 0):
			_spawn_wave(wave, i)
			_spawned_wave_indices[i] = true

func _spawn_wave(wave: Dictionary, wave_index: int) -> void:
	var count := int(wave.get("count", 1))
	for j in range(count):
		_spawn_single_enemy(wave, wave_index)
	if count > 0:
		_active_wave_counts[wave_index] = _active_wave_counts.get(wave_index, 0) + count
	if _event_bus:
		_event_bus.emit_safe("wave_spawned", [wave])

func _spawn_single_enemy(wave: Dictionary, wave_index: int) -> void:
	if _catalog == null:
		return
	var key = wave.get("enemy", "default_enemy")
	var enemy: Node = _catalog.instantiate(key)
	if enemy == null:
		return
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = _spawn_position(wave)
	enemy.set_meta("spawn_wave_index", wave_index)
	if _event_bus:
		_event_bus.emit_safe("enemy_spawned", [enemy])

func _spawn_position(wave: Dictionary) -> Vector2:
	var radius := float(wave.get("radius", 300))
	var hero_pos := _hero.global_position if _hero else Vector2.ZERO
	var angle := randf() * TAU
	var offset := Vector2.RIGHT.rotated(angle) * radius
	return hero_pos + offset

func set_hero_reference(hero: Node2D) -> void:
	_hero = hero

func _on_enemy_died(enemy: Node, _source: Node) -> void:
	if enemy == null:
		return
	if not enemy.has_meta("spawn_wave_index"):
		return
	var wave_index = int(enemy.get_meta("spawn_wave_index"))
	if not _active_wave_counts.has(wave_index):
		return
	_active_wave_counts[wave_index] -= 1
	if _active_wave_counts[wave_index] <= 0:
		_active_wave_counts.erase(wave_index)
		var wave: Dictionary = _wave_lookup.get(wave_index, {})
		if _event_bus:
			_event_bus.emit_safe("wave_completed", [wave_index, wave])
