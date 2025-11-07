extends Character

class_name HeroCharacter

const MovementSystem = preload("res://scripts/systems/movement_system.gd")

@export var accel := 1600.0
@export var friction := 1200.0
@export var projectile_scene : PackedScene
@export var fire_interval := 0.6
@export var projectile_speed := 700.0

var _move_input := Vector2.ZERO
var _touch_id := -1
var _touch_origin := Vector2.ZERO
var _touch_vector := Vector2.ZERO

@onready var fire_timer : Timer = _ensure_timer()

func _ensure_timer() -> Timer:
	var timer = get_node_or_null("FireTimer")
	if not timer:
		timer = Timer.new()
		timer.name = "FireTimer"
		timer.wait_time = fire_interval
		timer.one_shot = false
		add_child(timer)
	return timer

func _ready() -> void:
	super._ready()
	set_process_unhandled_input(true)
	fire_timer.wait_time = fire_interval
	fire_timer.timeout.connect(_fire_projectile)
	fire_timer.start()

func _unhandled_input(event: InputEvent) -> void:
	var viewport_width = get_viewport_rect().size.x
	if event is InputEventScreenTouch:
		if event.pressed and event.position.x < viewport_width * 0.6:
			_touch_id = event.index
			_touch_origin = event.position
			_touch_vector = Vector2.ZERO
		elif not event.pressed and event.index == _touch_id:
			_touch_id = -1
			_touch_vector = Vector2.ZERO
	elif event is InputEventScreenDrag and event.index == _touch_id:
		var delta = event.position - _touch_origin
		_touch_vector = delta / 80.0
		if _touch_vector.length() > 1.0:
			_touch_vector = _touch_vector.normalized()

func _physics_process(_delta: float) -> void:
	_move_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if _move_input == Vector2.ZERO:
		_move_input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if _move_input == Vector2.ZERO and _touch_id != -1:
		_move_input = _touch_vector
	MovementSystem.apply_input_with_accel(self, _move_input, move_speed, accel, friction, _delta)

func _fire_projectile() -> void:
	if not projectile_scene or not is_enabled:
		return
	var direction = _get_target_direction()
	if direction == Vector2.ZERO:
		return
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	projectile.direction = direction
	projectile.speed = projectile_speed
	projectile.damage = base_damage
	get_tree().current_scene.add_child(projectile)

func _get_target_direction() -> Vector2:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest_dir = Vector2.ZERO
	var closest_distance = INF
	for enemy in enemies:
		if not enemy is Node2D or not enemy.is_inside_tree() or not enemy.is_enabled:
			continue
		var distance = global_position.distance_squared_to(enemy.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_dir = (enemy.global_position - global_position).normalized()
	return closest_dir
