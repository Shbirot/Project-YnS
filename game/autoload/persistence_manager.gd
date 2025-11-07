extends Node

## Periodically captures runtime state (positions, config overrides, etc.) and persists to disk.
const SAVE_PATH := "user://persistence.json"
const SNAPSHOT_INTERVAL := 30.0

var _timer : Timer
var _data : Dictionary = {}

func _ready() -> void:
	_timer = Timer.new()
	_timer.wait_time = SNAPSHOT_INTERVAL
	_timer.autostart = true
	_timer.timeout.connect(_capture_and_save)
	add_child(_timer)
	_load_state()

func _load_state() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var parsed = JSON.parse_string(file.get_as_text())
		if typeof(parsed) == TYPE_DICTIONARY:
			_data = parsed
	_apply_state()

func _apply_state() -> void:
	var hero_state = _data.get("hero", {})
	var hero = _get_hero()
	if hero_state and hero:
		hero.global_position = hero_state.get("position", hero.global_position)
		hero.coins = hero_state.get("coins", hero.coins)
		if hero.has_method("apply_snapshot_data"):
			hero.apply_snapshot_data(hero_state)
	_restore_obstacles(_data.get("obstacles", []))

func _capture_and_save() -> void:
	_capture_state()
	_save_state()

func _capture_state() -> void:
	_data = {}
	var hero = _get_hero()
	if hero:
		_data["hero"] = {
			"position": hero.global_position,
			"coins": hero.coins,
		}
		if hero.has_method("get_snapshot_data"):
			_data["hero"].merge(hero.get_snapshot_data(), true)
	_data["obstacles"] = _snapshot_obstacles()

func _save_state() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_data, "\t"))

func _snapshot_obstacles() -> Array:
	var output : Array = []
	for obstacle in get_tree().get_nodes_in_group("obstacles"):
		if obstacle.has_method("serialize_state") and obstacle.persistent and not obstacle.get_meta("runtime_spawned", false):
			var record = obstacle.serialize_state()
			if record.get("scene", "") != "":
				output.append(record)
	return output

func _restore_obstacles(obstacles: Array) -> void:
	_clear_runtime_obstacles()
	var world = _get_world_node()
	if world == null:
		return
	for state in obstacles:
		if not state is Dictionary:
			continue
		var scene_path = state.get("scene", "")
		if scene_path == "":
			continue
		var packed : PackedScene = load(scene_path)
		if packed == null:
			continue
		var instance = packed.instantiate()
		if not instance:
			continue
		instance.set_meta("runtime_spawned", true)
		if instance.has_variable("persistent"):
			instance.persistent = true
		world.add_child(instance)
		if instance.has_method("apply_serialized_state"):
			instance.apply_serialized_state(state)

func _clear_runtime_obstacles() -> void:
	for obstacle in get_tree().get_nodes_in_group("obstacles"):
		if obstacle.get_meta("runtime_spawned", false):
			obstacle.queue_free()

func _get_world_node():
	var scene = get_tree().current_scene
	if scene and scene.has_node("World"):
		return scene.get_node("World")
	return scene

func _get_hero():
	var heroes = get_tree().get_nodes_in_group("heroes")
	return heroes[0] if heroes.size() > 0 else null
