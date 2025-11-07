extends Node2D

@onready var player = $World/Player
@onready var spawner = $EnemySpawner
@onready var hud = $CanvasLayer/HUD

var _elapsed := 0.0
var _is_game_over := false
var _debug_spawn_enabled := true
var _kill_count := 0

func _ready() -> void:
	set_process_input(true)
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

func _random_point_near_player() -> Vector2:
	var distance = 400.0
	var angle = randf() * TAU
	return player.global_position + Vector2.RIGHT.rotated(angle) * distance

func _on_enemy_killed() -> void:
	_kill_count += 1
	hud.update_kills(_kill_count)

func _connect_enemies() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.has_signal("died"):
			enemy.died.connect(_on_enemy_killed)
