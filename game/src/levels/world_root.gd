extends Node2D

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")
const TestInputDriver = preload("res://tests/sim/input_driver.gd")
const DebugUtils = preload("res://src/shared/scripts/debug_utils.gd")

@export var hero_path: NodePath
@export var camera_rig_path: NodePath
@export var spawner_controller_path: NodePath

var hero: Node
var camera_rig: Node
var spawner: Node
var _input_driver: Node

func _ready() -> void:
	hero = get_node_or_null(hero_path)
	camera_rig = get_node_or_null(camera_rig_path)
	spawner = get_node_or_null(spawner_controller_path)
	var logger = SingletonUtil.get_logger()
	if logger:
		logger.info("WorldRoot ready", {
			"hero": hero_path,
			"camera": camera_rig_path,
			"spawner": spawner_controller_path,
		})

	if hero == null:
		push_error("WorldRoot: hero_path is not assigned.")
	if camera_rig == null:
		push_error("WorldRoot: camera_rig_path is not assigned.")
	if spawner == null:
		push_warning("WorldRoot: spawner_controller_path not assigned (using placeholder).")
	if spawner and spawner.has_method("set_hero_reference"):
		spawner.set_hero_reference(hero)
	_connect_event_bus()
	_spawn_input_driver()

func _connect_event_bus() -> void:
	var event_bus: Node = SingletonUtil.get_event_bus()
	if event_bus == null or hero == null:
		DebugUtils.debug_log("WorldRoot missing event bus or hero", {"hero": hero})
		return
	if not event_bus.is_connected("hero_spawned", Callable(self, "_on_hero_spawned")):
		event_bus.connect("hero_spawned", Callable(self, "_on_hero_spawned"))
	if not event_bus.is_connected("hero_died", Callable(self, "_on_hero_died")):
		event_bus.connect("hero_died", Callable(self, "_on_hero_died"))
	event_bus.emit_signal("hero_spawned", hero)

func _on_hero_spawned(hero_ref: Node) -> void:
	if camera_rig and camera_rig.has_method("set_target"):
		camera_rig.set_target(hero_ref.get_node("CameraTarget") if hero_ref.has_node("CameraTarget") else hero_ref)

func _on_hero_died(hero_ref: Node) -> void:
	if camera_rig and camera_rig.has_method("clear_target"):
		camera_rig.clear_target()

func _spawn_input_driver() -> void:
	var cfg = SingletonUtil.get_game_config()
	if cfg == null:
		DebugUtils.debug_log("Input driver skipped: no GameConfig", {})
		return
	var script_path: String = str(cfg.get_env_value("NF_INPUT_SCRIPT_PATH", ""))
	if script_path == "":
		DebugUtils.debug_log("Input driver disabled: NF_INPUT_SCRIPT_PATH empty", {})
		return
	var driver = TestInputDriver.new()
	driver.load_script(script_path)
	add_child(driver)
	DebugUtils.debug_log("Input driver spawned", {"script": script_path})
	_input_driver = driver
