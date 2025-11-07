extends Node2D

const WorldBounds = preload("res://scripts/systems/world_bounds.gd")
const Log = preload("res://scripts/utils/log_helper.gd")

@onready var player = $World/Player
@onready var spawner = $EnemySpawner
@onready var background = $World/Background
@onready var camera_controller = $World/Camera
@onready var hud = $CanvasLayer/HUD

var _elapsed := 0.0
var _is_game_over := false
var _debug_spawn_enabled := true
var _kill_count := 0
const OBSTACLE_SCENES = [
	preload("res://scenes/immovable_stone.tscn"),
	preload("res://scenes/immovable_tree.tscn"),
	preload("res://scenes/immovable_bush.tscn"),
]

func _ready() -> void:
	set_process_input(true)
	_reset_background()
	spawner.set_player(player)
	player.health_changed.connect(hud.update_health)
	player.player_died.connect(_on_player_died)
	hud.update_health(player.max_health, player.max_health)
	hud.set_status_text("Survive the night")
	_connect_enemies()

func _process(delta: float) -> void:
	if _is_game_over:
		return
	_elapsed += delta
	hud.update_timer(_elapsed)

func _on_player_died() -> void:
	_is_game_over = true
	hud.set_status_text("You were overwhelmed!")
	spawner.stop()

func _input(event: InputEvent) -> void:
	if not _debug_spawn_enabled:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			_spawn_enemy_debug()
		elif event.keycode == KEY_R:
			_spawn_coin_debug()
		elif event.keycode == KEY_O:
			_spawn_obstacle_debug()

func _spawn_enemy_debug() -> void:
	var enemy_scene = preload("res://scenes/enemy.tscn")
	var enemy = enemy_scene.instantiate()
	enemy.global_position = _random_point_near_player()
	enemy.initialize(player)
	enemy.died.connect(_on_enemy_killed)
	get_tree().current_scene.add_child(enemy)

func _spawn_coin_debug() -> void:
	var coin_scene = preload("res://scenes/collectible_coin.tscn")
	var coin = coin_scene.instantiate()
	coin.global_position = _random_point_near_player()
	get_tree().current_scene.add_child(coin)

func _spawn_obstacle_debug() -> void:
	if OBSTACLE_SCENES.is_empty():
		return
	var world = player.get_parent()
	var spawned := 0
	for scene in OBSTACLE_SCENES:
		for i in range(15):
			var obstacle = scene.instantiate()
			obstacle.global_position = _random_world_point()
			obstacle.set_meta("runtime_spawned", true)
			if "persistent" in obstacle:
				obstacle.persistent = true
			world.add_child(obstacle)
			spawned += 1
	Log.info("Spawned %d debug obstacles" % spawned)

func _random_point_near_player() -> Vector2:
	var distance = 400.0
	var angle = randf() * TAU
	return player.global_position + Vector2.RIGHT.rotated(angle) * distance

func _random_world_point() -> Vector2:
	var rect = _get_background_rect()
	return Vector2(
		randf_range(rect.position.x, rect.position.x + rect.size.x),
		randf_range(rect.position.y, rect.position.y + rect.size.y)
	)

func _on_enemy_killed() -> void:
	_kill_count += 1
	hud.update_kills(_kill_count)

func _connect_enemies() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.has_signal("died"):
			enemy.died.connect(_on_enemy_killed)

func _reset_background() -> void:
	if not is_instance_valid(background):
		return
	var rect = _get_background_rect()
	background.position = rect.position
	if camera_controller:
		camera_controller.set_world_bounds(rect)
	WorldBounds.set_rect(rect)

func _get_background_rect() -> Rect2:
	if not is_instance_valid(background):
		return Rect2(-1500, -1500, 3000, 3000)
	if background.scale == Vector2.ZERO:
		background.scale = Vector2.ONE
	var tex_size = Vector2(0, 0)
	if background.texture:
		tex_size = background.texture.get_size()
	var scaled_size = tex_size * background.scale
	if scaled_size == Vector2.ZERO:
		scaled_size = Vector2(3000, 3000)
	var position = -scaled_size * 0.5
	return Rect2(position, scaled_size)
