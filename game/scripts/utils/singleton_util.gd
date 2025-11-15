extends RefCounted
class_name SingletonUtil

## Utility for accessing autoload singletons
## Provides type-safe, cached access to common game singletons

static var _event_bus = null
static var _level_manager = null
static var _rework_catalog = null
static var _game_config = null
static var _damage_system = null
static var _projectile_pool = null

static func get_event_bus():
	if _event_bus == null:
		_event_bus = _get_autoload("EventBus")
	return _event_bus

static func get_level_manager():
	if _level_manager == null:
		_level_manager = _get_autoload("LevelManager")
	return _level_manager

static func get_rework_catalog():
	if _rework_catalog == null:
		_rework_catalog = _get_autoload("ReworkCatalog")
	return _rework_catalog

static func get_game_config():
	if _game_config == null:
		_game_config = _get_autoload("GameConfig")
	return _game_config

static func get_damage_system():
	if _damage_system == null:
		_damage_system = _get_autoload("DamageSystem")
	return _damage_system

static func get_projectile_pool():
	if _projectile_pool == null:
		_projectile_pool = _get_autoload("ProjectilePool")
	return _projectile_pool

## Clear all cached references (useful for tests)
static func clear_cache() -> void:
	_event_bus = null
	_level_manager = null
	_rework_catalog = null
	_game_config = null
	_damage_system = null
	_projectile_pool = null

## Internal helper to get autoload by name
static func _get_autoload(name: String):
	var loop = Engine.get_main_loop()
	if not loop is SceneTree:
		push_warning("SingletonUtil: Engine.get_main_loop() is not SceneTree")
		return null
	var root = loop.get_root()
	if root == null:
		push_warning("SingletonUtil: SceneTree root is null")
		return null
	var node = root.get_node_or_null(name)
	if node == null:
		push_warning("SingletonUtil: Autoload '%s' not found" % name)
	return node
