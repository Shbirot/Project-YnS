extends Area2D

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")

@export var xp_value := 10
@export var magnet_speed := 180.0
@export var pickup_radius := 48.0

var _hero: Node2D
var _event_bus: Node

func _ready() -> void:
	_apply_env_overrides()
	body_entered.connect(_on_body_entered)
	_event_bus = SingletonUtil.get_event_bus()

func _physics_process(delta: float) -> void:
	if _hero == null:
		_hero = _find_hero()
	if _hero == null:
		return
	var distance := global_position.distance_to(_hero.global_position)
	if distance <= pickup_radius:
		var direction := ( _hero.global_position - global_position ).normalized()
		global_position += direction * magnet_speed * delta

func _on_body_entered(body: Node) -> void:
	if body.name == "Hero" or body.is_in_group("hero"):
		_collect()

func _collect() -> void:
	if _event_bus:
		_event_bus.emit_safe("xp_collected", [xp_value, global_position])
	queue_free()

func _find_hero() -> Node2D:
	return get_tree().get_first_node_in_group("hero")

func _apply_env_overrides() -> void:
	var cfg = SingletonUtil.get_game_config()
	xp_value = cfg.get_env_value("NF_XP_VALUE", xp_value)
	magnet_speed = cfg.get_env_value("NF_XP_MAGNET_SPEED", magnet_speed)
	pickup_radius = cfg.get_env_value("NF_XP_PICKUP_RADIUS", pickup_radius)
