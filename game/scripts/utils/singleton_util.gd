extends RefCounted
class_name SingletonUtil

## Utility for accessing autoload singletons
## Provides type-safe, cached access to common game singletons

# Cached references
static var _api_manager = null
static var _game_controller = null
static var _logger = null
static var _config_manager = null
static var _persistence_manager = null
static var _object_catalog = null

## Get APIManager singleton
## This is the primary game API - use this for all game state access
static func get_api_manager():
	if _api_manager == null:
		_api_manager = _get_autoload("APIManager")
	return _api_manager

## Get GameController singleton
static func get_game_controller():
	if _game_controller == null:
		_game_controller = _get_autoload("GameController")
	return _game_controller

## Get Logger singleton
static func get_logger():
	if _logger == null:
		_logger = _get_autoload("Logger")
	return _logger

## Get ConfigManager singleton
static func get_config_manager():
	if _config_manager == null:
		_config_manager = _get_autoload("ConfigManager")
	return _config_manager

## Get PersistenceManager singleton
static func get_persistence_manager():
	if _persistence_manager == null:
		_persistence_manager = _get_autoload("PersistenceManager")
	return _persistence_manager

## Get ObjectCatalog singleton
static func get_object_catalog():
	if _object_catalog == null:
		_object_catalog = _get_autoload("ObjectCatalog")
	return _object_catalog

## Clear all cached references (useful for tests)
static func clear_cache() -> void:
	_api_manager = null
	_game_controller = null
	_logger = null
	_config_manager = null
	_persistence_manager = null
	_object_catalog = null

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
