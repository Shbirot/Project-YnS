extends Node

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")
const EnemyArchetypeRegistry = preload("res://src/features/enemy/enemy_archetype_registry.gd")
const WaveConfigCache = preload("res://src/shared/scripts/wave_config_cache.gd")

@export var wave_config_path = "res://config/data/waves.json"
@export var archetype_dir = "res://config/enemies"
@export var spawn_padding = 64.0

var _waves: Array = []
var _spawned_wave_indices: Dictionary = {}
var _elapsed = 0.0
var _event_bus: Node
var _catalog: Node
var _hero: Node2D
var _active_wave_counts: Dictionary = {}
var _wave_lookup: Dictionary = {}
var _enemy_pool: Node
var _archetypes: Dictionary = {}

func _ready() -> void:
	_event_bus = SingletonUtil.get_event_bus()
	_catalog = SingletonUtil.get_game_catalog()
	_enemy_pool = SingletonUtil.get_enemy_pool()
	var logger = SingletonUtil.get_logger()
	if logger:
		logger.info("Spawner ready", {"config_path": wave_config_path})
	var cfg = SingletonUtil.get_game_config()
	wave_config_path = cfg.get_env_value("NF_WAVE_CONFIG_PATH", wave_config_path)
	spawn_padding = cfg.get_env_value("NF_SPAWN_PADDING", spawn_padding)
	_load_archetypes()
	_load_waves()
	if _event_bus:
		if not _event_bus.is_connected("enemy_died", Callable(self, "_on_enemy_died")):
			_event_bus.connect("enemy_died", Callable(self, "_on_enemy_died"))

func _process(delta: float) -> void:
	_elapsed += delta
	_try_spawn()

func _load_waves() -> void:
	var data = WaveConfigCache.get_wave_config(wave_config_path)
	_waves = data.get("waves", [])
	for i in range(_waves.size()):
		_wave_lookup[i] = _waves[i]

func _load_archetypes() -> void:
	_archetypes = EnemyArchetypeRegistry.load_archetypes(archetype_dir)
	var logger = SingletonUtil.get_logger()
	if logger:
		logger.info("Archetypes loaded", {"count": _archetypes.size(), "dir": archetype_dir})

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
	var entries: Array = wave.get("spawns", wave.get("enemies", []))
	if entries.is_empty():
		var default_wave = {"archetype": wave.get("archetype", wave.get("enemy", "basic_swarmer")), "count": wave.get("count", 1)}
		entries = [default_wave]
	for entry in entries:
		var type: String = entry.get("archetype", entry.get("type", "basic_swarmer"))
		var count = int(entry.get("count", 1))
		for j in range(count):
			_spawn_single_enemy(type, wave, wave_index)
		if count > 0:
			_active_wave_counts[wave_index] = _active_wave_counts.get(wave_index, 0) + count
	if _event_bus:
		_event_bus.emit_safe("wave_spawned", [wave])
	var logger = SingletonUtil.get_logger()
	if logger:
		logger.info("Wave spawned", {"index": wave_index, "entries": entries.size()})

func _spawn_single_enemy(enemy_type: String, wave: Dictionary, wave_index: int) -> void:
	var archetype: EnemyArchetype = _archetypes.get(enemy_type, null)
	var packed: PackedScene = archetype.scene if archetype else null
	if packed == null and _catalog:
		var scene_path: String = _catalog.get_scene_path(enemy_type)
		if scene_path != "":
			packed = load(scene_path)
	if packed == null:
		var logger = SingletonUtil.get_logger()
		if logger:
			logger.warn("Spawner missing archetype scene", {"archetype": enemy_type})
		return
	var enemy: Node = null
	if _enemy_pool:
		enemy = _enemy_pool.fetch_enemy(packed)
	else:
		enemy = packed.instantiate()
	if enemy == null:
		return
	var world = get_tree().current_scene
	if world and enemy.get_parent() != world:
		if enemy.get_parent():
			enemy.get_parent().remove_child(enemy)
		world.add_child(enemy)
	enemy.set_meta("spawn_wave_index", wave_index)
	if archetype and enemy is MonsterBase:
		enemy.configure_from_archetype(archetype)
	var position = _spawn_position(wave)
	if enemy.has_method("prepare_for_spawn"):
		enemy.prepare_for_spawn(position)
	if _event_bus:
		_event_bus.emit_safe("enemy_spawned", [enemy])

func _spawn_position(wave: Dictionary) -> Vector2:
	var radius = float(wave.get("radius", 300))
	var hero_pos = _hero.global_position if _hero else Vector2.ZERO
	var angle = randf() * TAU
	var offset = Vector2.RIGHT.rotated(angle) * radius
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
