extends Node

const SingletonUtil = preload("res://scripts/utils/singleton_util.gd")

@export var wave_config_path := "res://config/data/rework_waves.json"
@export var spawn_padding := 64.0

var _waves: Array = []
var _spawned_wave_indices: Dictionary = {}
var _elapsed := 0.0
var _event_bus: Node
var _catalog: Node
var _hero: Node2D

func _ready() -> void:
	_event_bus = SingletonUtil.get_event_bus()
	_catalog = SingletonUtil.get_rework_catalog()
	var cfg = SingletonUtil.get_game_config()
	wave_config_path = cfg.get_env_value("NF_WAVE_CONFIG_PATH", wave_config_path)
	spawn_padding = cfg.get_env_value("NF_SPAWN_PADDING", spawn_padding)
	_load_waves()

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

func _try_spawn() -> void:
	_hero = _hero if _hero else get_tree().get_first_node_in_group("hero")
	for i in range(_waves.size()):
		if _spawned_wave_indices.has(i):
			continue
		var wave: Dictionary = _waves[i]
		if _elapsed >= wave.get("time", 0):
			_spawn_wave(wave)
			_spawned_wave_indices[i] = true

func _spawn_wave(wave: Dictionary) -> void:
	var count := int(wave.get("count", 1))
	for j in range(count):
		_spawn_single_enemy(wave)
	if _event_bus:
		_event_bus.emit_safe("wave_spawned", [wave])

func _spawn_single_enemy(wave: Dictionary) -> void:
	if _catalog == null:
		return
	var key = wave.get("enemy", "default_enemy")
	var enemy: Node = _catalog.instantiate(key)
	if enemy == null:
		return
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = _spawn_position(wave)
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
