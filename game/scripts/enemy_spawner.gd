extends Node

@export var enemy_scene : PackedScene
@export var spawn_interval := 1.5
@export var spawn_radius := 500.0
@export var max_enemies := 100

var _player : Node2D
var _timer : Timer

func _ready() -> void:
	_apply_config()
	randomize()
	_timer = Timer.new()
	_timer.one_shot = false
	_timer.wait_time = spawn_interval * GameConfig.get_setting("enemy_spawn_rate", 1.0)
	_timer.timeout.connect(_spawn_enemy)
	add_child(_timer)
	_timer.start()
	_timer.paused = true

func set_player(player: Node2D) -> void:
	_player = player

func _spawn_enemy() -> void:
	if not enemy_scene or not is_instance_valid(_player):
		return
	var current_count = get_tree().get_nodes_in_group("enemies").size()
	if current_count >= max_enemies:
		return
	var enemy = enemy_scene.instantiate()
	enemy.global_position = _pick_spawn_position()
	enemy.initialize(_player)
	get_tree().current_scene.add_child(enemy)

func _pick_spawn_position() -> Vector2:
	var angle = randf() * TAU
	var offset = Vector2.RIGHT.rotated(angle) * spawn_radius
	return _player.global_position + offset

func stop() -> void:
	if _timer:
		_timer.stop()

func _apply_config() -> void:
	spawn_interval = ConfigManager.get_value("spawner.spawn_interval", spawn_interval)
	spawn_radius = ConfigManager.get_value("spawner.spawn_radius", spawn_radius)
	max_enemies = int(ConfigManager.get_value("spawner.max_enemies", max_enemies))
