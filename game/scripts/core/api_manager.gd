extends Node

## APIManager - Global Facade/Gateway for all game systems
##
## This is the primary API for accessing game state and triggering game actions.
## All game systems should route through APIManager instead of accessing managers directly.
##
## Usage:
##   APIManager.damage_hero(10, enemy)
##   APIManager.heal_hero(20)
##   var hp = APIManager.get_hero_hp()
##   APIManager.hero_hp_changed.connect(hud.update_health)

const Log = preload("res://scripts/utils/log_helper.gd")

## ============================================
## SIGNALS - Centralized game events
## ============================================

## Emitted when hero HP changes
signal hero_hp_changed(current: int, max_hp: int)

## Emitted when hero dies
signal hero_died(source)

## Emitted when hero attribute changes
signal hero_attribute_changed(key: String, value)

## ============================================
## MANAGER REFERENCES
## ============================================

var _attributes_manager: AttributesManager = null
var _damage_number_manager = null
var _game_controller = null

## ============================================
## INITIALIZATION
## ============================================

func _ready() -> void:
	Log.info("APIManager: Initializing global game API")
	_connect_to_managers()

func initialize_with_managers(game_controller, attributes_manager, damage_number_manager) -> void:
	_game_controller = game_controller
	_attributes_manager = attributes_manager
	_damage_number_manager = damage_number_manager
	Log.info("APIManager: Managers connected")

func _connect_to_managers() -> void:
	# Get managers from GameController or scene tree
	var controller = Engine.get_main_loop().root.get_node_or_null("GameController")
	if controller:
		_game_controller = controller
		if controller.has_method("get_attributes_manager"):
			_attributes_manager = controller.get_attributes_manager()
		if controller.has_method("get_damage_number_manager"):
			_damage_number_manager = controller.get_damage_number_manager()
		Log.info("APIManager: Connected to GameController")

## ============================================
## HERO HP API
## ============================================

## Apply damage to hero
## Emits hero_hp_changed signal
## Emits hero_died signal if HP reaches 0
func damage_hero(amount: int, source = null) -> void:
	if _attributes_manager == null:
		Log.warn("APIManager: Cannot damage hero - AttributesManager not available")
		return

	if amount <= 0:
		Log.warn("APIManager: Invalid damage amount %d from %s" % [amount, _get_source_name(source)])
		return

	var old_hp = _attributes_manager.get_current_hp()
	var new_hp = _attributes_manager.apply_damage(amount)
	var max_hp = _attributes_manager.get_max_hp()

	Log.info("APIManager: Hero damaged %d (%d->%d) by %s" % [amount, old_hp, new_hp, _get_source_name(source)])

	# Emit HP changed signal
	hero_hp_changed.emit(new_hp, max_hp)

	# Check for death
	if new_hp <= 0 and old_hp > 0:
		Log.warn("APIManager: Hero died from %s" % _get_source_name(source))
		hero_died.emit(source)

## Heal hero
## Emits hero_hp_changed signal
func heal_hero(amount: int) -> void:
	if _attributes_manager == null:
		Log.warn("APIManager: Cannot heal hero - AttributesManager not available")
		return

	if amount <= 0:
		return

	var old_hp = _attributes_manager.get_current_hp()
	var new_hp = _attributes_manager.heal(amount)
	var max_hp = _attributes_manager.get_max_hp()

	Log.info("APIManager: Hero healed %d (%d->%d)" % [amount, old_hp, new_hp])
	hero_hp_changed.emit(new_hp, max_hp)

## Kill hero instantly
func kill_hero(source = null) -> void:
	if _attributes_manager == null:
		return
	var current_hp = _attributes_manager.get_current_hp()
	if current_hp > 0:
		damage_hero(current_hp, source)

## Get hero current HP
func get_hero_hp() -> int:
	if _attributes_manager:
		return _attributes_manager.get_current_hp()
	return 0

## Get hero max HP
func get_hero_max_hp() -> int:
	if _attributes_manager:
		return _attributes_manager.get_max_hp()
	return 100

## Set hero max HP (also updates current HP if needed)
func set_hero_max_hp(value: int) -> void:
	if _attributes_manager == null:
		return
	var old_max = _attributes_manager.get_max_hp()
	_attributes_manager.set_max_hp(value)
	var new_max = _attributes_manager.get_max_hp()
	var current = _attributes_manager.get_current_hp()

	Log.info("APIManager: Hero max HP changed %d->%d (current=%d)" % [old_max, new_max, current])
	hero_hp_changed.emit(current, new_max)

## Set hero current HP directly
func set_hero_hp(value: int) -> void:
	if _attributes_manager == null:
		return
	_attributes_manager.set_current_hp(value)
	var current = _attributes_manager.get_current_hp()
	var max_hp = _attributes_manager.get_max_hp()
	hero_hp_changed.emit(current, max_hp)

## Check if hero is dead
func is_hero_dead() -> bool:
	if _attributes_manager:
		return _attributes_manager.is_dead()
	return false

## ============================================
## HERO ATTRIBUTES API
## ============================================

## Set hero attribute
func set_hero_attribute(key: String, value) -> void:
	if _attributes_manager == null:
		return
	_attributes_manager.set_attribute(key, value)
	hero_attribute_changed.emit(key, value)

## Get hero attribute with default fallback
func get_hero_attribute(key: String, default_value = null):
	if _attributes_manager:
		return _attributes_manager.get_attribute(key, default_value)
	return default_value

## Get all hero attributes (including HP)
func get_all_hero_attributes() -> Dictionary:
	if _attributes_manager:
		return _attributes_manager.get_all_attributes()
	return {}

## ============================================
## VISUAL EFFECTS API
## ============================================

## Show damage number visual effect
func show_damage_number(damage: float, damage_type: String, is_crit: bool, position: Vector2) -> void:
	if _damage_number_manager and _damage_number_manager.has_method("show_damage"):
		_damage_number_manager.show_damage(damage, damage_type, is_crit, position)

## ============================================
## GAME CONTROL API (delegated to GameController)
## ============================================

func pause_game() -> void:
	if _game_controller and _game_controller.has_method("pause_game"):
		_game_controller.pause_game()

func resume_game() -> void:
	if _game_controller and _game_controller.has_method("resume_game"):
		_game_controller.resume_game()

func reset_game() -> void:
	if _game_controller and _game_controller.has_method("reset_game"):
		_game_controller.reset_game()

func show_window(window_name: String) -> void:
	if _game_controller and _game_controller.has_method("show_window"):
		_game_controller.show_window(window_name)

func hide_window(window_name: String) -> void:
	if _game_controller and _game_controller.has_method("hide_window"):
		_game_controller.hide_window(window_name)

## ============================================
## INTERNAL HELPERS
## ============================================

func _get_source_name(source) -> String:
	if source == null:
		return "unknown"
	if source.has_method("get_display_name"):
		return source.get_display_name()
	if "display_name" in source:
		return source.display_name
	if "name" in source:
		return source.name
	return "source"
