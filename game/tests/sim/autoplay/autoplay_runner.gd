extends SceneTree

const AutoplayAgent = preload("res://tests/sim/autoplay/autoplay_agent.gd")
const ConfigLoader = preload("res://src/shared/scripts/config_loader.gd")

var default_config_path = "res://tests/sim/autoplay/autoplay_basic.json"
var fallback_scene = "res://src/levels/main.tscn"

var _agent: AutoplayAgent
var _config_path = ""

func _initialize() -> void:
	call_deferred("_boot")

func _boot() -> void:
	_config_path = _config_path_from_args()
	var config = _load_config(_config_path)
	var scene_path = config.get("scene", fallback_scene)
	var packed_scene = load(scene_path)
	if packed_scene == null:
		push_error("[autoplay_runner] Failed to load scene: %s" % scene_path)
		quit()
		return
	var world = packed_scene.instantiate()
	var root = get_root()
	root.add_child(world)
	current_scene = world
	await process_frame
	_agent = AutoplayAgent.new()
	_agent.setup(config)
	var hero_node = world.get_node_or_null("Hero")
	if hero_node:
		_agent.set_hero_reference(hero_node)
	world.add_child(_agent)
	_agent.connect("simulation_finished", Callable(self, "_on_simulation_finished"))
	print("[autoplay_runner] Running config: %s" % _config_path)

func _config_path_from_args() -> String:
	var path = default_config_path
	var args = OS.get_cmdline_user_args()
	for i in range(args.size()):
		if args[i] == "--config" and i + 1 < args.size():
			path = args[i + 1]
	return path

func _load_config(path: String) -> Dictionary:
	var config = ConfigLoader.load_autoplay_config(path)
	if config.is_empty():
		push_warning("[autoplay_runner] Invalid config %s – using defaults." % path)
		return {
			"scene": fallback_scene,
			"duration": 20
		}
	if config.get("magic", "") != "NF_AUTOPLAY_V1":
		push_warning("[autoplay_runner] Autoplay magic mismatch – using defaults.")
		return {
			"scene": fallback_scene,
			"duration": 20
		}
	return config

func _on_simulation_finished(metrics: Dictionary) -> void:
	print("[autoplay_runner] Simulation finished: %s" % JSON.stringify(metrics))
	var world = _agent.get_parent()
	if world:
		var root = get_root()
		if current_scene == world:
			current_scene = null
		if root and world.get_parent() == root:
			root.remove_child(world)
		world.queue_free()
	quit()
