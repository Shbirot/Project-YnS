extends Node

const ApiManager = preload("res://scripts/core/api_manager.gd")
const GameWindow = preload("res://scripts/ui/game_window.gd")
const AttributesManager = preload("res://scripts/core/attributes_manager.gd")
const DamageNumberManager = preload("res://scripts/effects/damage_number_manager.gd")
const Log = preload("res://scripts/utils/log_helper.gd")
const SceneTreeUtil = preload("res://scripts/utils/scene_tree_util.gd")

var _logger
var _config_manager
var _persistence_manager
var _menus := {}
var _windows := {}
var _api_manager : ApiManager
var _initialized := false
var _attributes_manager : AttributesManager
var _damage_manager : DamageNumberManager
var _selected_hero_id := ""
var _selected_weapon_id := ""

func _ready() -> void:
	# Initialize immediately when GameController loads (before main scene)
	# This ensures AttributesManager is available for any characters that load
	initialize()

func initialize() -> void:
	if _initialized:
		return
	_logger = SceneTreeUtil.get_autoload("Logger")
	_config_manager = SceneTreeUtil.get_autoload("ConfigManager")
	_persistence_manager = SceneTreeUtil.get_autoload("PersistenceManager")
	_setup_menu_layer()
	var disable_api := false
	if OS.has_environment("DISABLE_API_MANAGER"):
		var value = OS.get_environment("DISABLE_API_MANAGER")
		disable_api = value != ""
	if not disable_api:
		_api_manager = ApiManager.new()
		add_child(_api_manager)
		_api_manager.start(self)
	_attributes_manager = AttributesManager.new()
	add_child(_attributes_manager)
	# AttributesManager initializes with defaults, no need to reset
	_damage_manager = DamageNumberManager.new()
	add_child(_damage_manager)
	_initialized = true

func is_initialized() -> bool:
	return _initialized

func start_main_scene() -> void:
	if not is_inside_tree():
		Log.warn("GameController: cannot load main scene (not inside tree)")
		return
	var packed: PackedScene = load("res://scenes/main.tscn")
	if packed:
		Log.info("GameController: loading main scene")
		get_tree().change_scene_to_packed(packed)
	else:
		Log.error("GameController: failed to load main scene")

func _setup_menu_layer() -> void:
	_register_menu("main_menu")
	_register_menu("pause_menu")

func _register_menu(name: String) -> void:
	_menus[name] = {
		"active": false,
		"state": {},
	}

func show_menu(name: String) -> void:
	if not _menus.has(name):
		Log.warn("GameController: tried to show unknown menu %s" % name)
		return
	_menus[name]["active"] = true

func hide_menu(name: String) -> void:
	if not _menus.has(name):
		Log.warn("GameController: tried to hide unknown menu %s" % name)
		return
	_menus[name]["active"] = false

func save_menu_state(name: String, state: Dictionary) -> void:
	if not _menus.has(name):
		_register_menu(name)
	_menus[name]["state"] = state

func get_menu_state(name: String) -> Dictionary:
	return _menus.get(name, {}).get("state", {})

func flush_menu_persistence() -> void:
	pass

func register_window(window: GameWindow) -> void:
	if window == null or window.window_name == "":
		Log.warn("GameController: attempt to register invalid window")
		return
	Log.debug("GameController: register window %s" % window.window_name)
	_windows[window.window_name] = window

func unregister_window(name: String) -> void:
	Log.debug("GameController: unregister window %s" % name)
	_windows.erase(name)

func show_window(name: String) -> void:
	if _windows.has(name):
		Log.info("GameController: showing window %s" % name)
		_windows[name].show_window()
	else:
		Log.warn("GameController: window %s not registered" % name)

func hide_window(name: String) -> void:
	if _windows.has(name):
		Log.info("GameController: hiding window %s" % name)
		_windows[name].hide_window()
func set_loadout(hero_id: String, weapon_id: String) -> void:
	_selected_hero_id = hero_id
	_selected_weapon_id = weapon_id

func get_loadout() -> Dictionary:
	return {
		"hero_id": _selected_hero_id,
		"weapon_id": _selected_weapon_id,
	}

func apply_loadout() -> void:
	if not is_inside_tree():
		Log.warn("GameController: cannot apply loadout (not inside tree)")
		return
	var scene = get_tree().current_scene
	if scene and scene.has_method("apply_loadout"):
		Log.info("GameController: applying loadout hero=%s weapon=%s" % [_selected_hero_id, _selected_weapon_id])
		scene.call_deferred("apply_loadout", _selected_hero_id, _selected_weapon_id)
	else:
		Log.warn("GameController: current scene missing apply_loadout")

func pause_game() -> void:
	if not is_inside_tree():
		Log.warn("GameController: cannot pause game (not inside tree)")
		return
	var tree = get_tree()
	if tree == null:
		Log.warn("GameController: cannot pause game (no scene tree)")
		return
	Log.info("GameController: pausing game")
	tree.paused = true

func resume_game() -> void:
	if not is_inside_tree():
		Log.warn("GameController: cannot resume game (not inside tree)")
		return
	var tree = get_tree()
	if tree == null:
		Log.warn("GameController: cannot resume game (no scene tree)")
		return
	Log.info("GameController: resuming game")
	tree.paused = false

func reset_game() -> void:
	if not is_inside_tree():
		Log.warn("GameController: cannot reset game (not inside tree)")
		return
	var tree = get_tree()
	if tree == null:
		Log.warn("GameController: cannot reset game (no scene tree)")
		return
	Log.info("GameController: resetting game")
	var current = tree.current_scene
	if current and current.scene_file_path != "":
		var packed = ResourceLoader.load(current.scene_file_path)
		if packed:
			tree.change_scene_to_packed(packed)
		else:
			Log.error("GameController: failed to reload scene %s" % current.scene_file_path)
	else:
		Log.warn("GameController: no current scene to reset")

func log_component_stats() -> void:
	var entries = []
	entries.append("Windows=%d" % _windows.size())
	entries.append("Menus=%d" % _menus.size())
	if _attributes_manager:
		entries.append("Attributes=%d" % _attributes_manager.get_all_attributes().size())
	for entry in entries:
		print("[GameController] %s" % entry)

func get_attributes_manager() -> AttributesManager:
	return _attributes_manager

func get_damage_number_manager() -> DamageNumberManager:
	return _damage_manager

# Attributes API - GameController is the gatekeeper for AttributesManager
func set_attribute(key: String, value) -> void:
	if _attributes_manager:
		_attributes_manager.set_attribute(key, value)

func get_attribute(key: String, default = null):
	if _attributes_manager:
		return _attributes_manager.get_attribute(key, default)
	return default

func get_all_attributes() -> Dictionary:
	if _attributes_manager:
		return _attributes_manager.get_all_attributes()
	return {}

func update_hero_attributes(stats: Dictionary) -> void:
	if _attributes_manager == null:
		Log.warn("GameController: cannot update attributes (manager not ready)")
		return
	for key in stats:
		_attributes_manager.set_attribute(key, stats[key])
