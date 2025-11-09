extends Character

class_name HeroCharacter

const MovementSystem = preload("res://scripts/systems/movement_system.gd")
const WorldBounds = preload("res://scripts/systems/world_bounds.gd")
const WeaponAmmunition = preload("res://scripts/weapons/ammunition_base.gd")
const SingletonUtil = preload("res://scripts/utils/singleton_util.gd")
const TargetFinderUtil = preload("res://scripts/utils/target_finder_util.gd")
const HALF_EXTENT := Vector2(20, 20)

@export var accel := 1600.0
@export var friction := 1200.0
@export var projectile_scene : PackedScene
@export var fire_interval := 0.6
@export var projectile_speed := 700.0

var _move_input := Vector2.ZERO
var _touch_id := -1
var _touch_origin := Vector2.ZERO
var _touch_vector := Vector2.ZERO
var _ammunition : WeaponAmmunition
var _damage_type := "physical"

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
	set_fire_interval_value(fire_interval)
	fire_timer.timeout.connect(_fire_projectile)
	fire_timer.start()
	# Report stats to APIManager once at the end after all initialization
	_report_stats_to_api_manager()
	_log_collision_geometry()
	Log.info("HeroCharacter ready: %s" % _log_name())

func _log_collision_geometry() -> void:
	var shape = get_node_or_null("CollisionShape2D")
	if shape and shape.shape:
		var shape_type = shape.shape.get_class()
		var shape_details = ""
		if shape.shape is CircleShape2D:
			shape_details = "radius=%.1f" % shape.shape.radius
		elif shape.shape is RectangleShape2D:
			shape_details = "size=%s (half_diagonal=%.1f)" % [shape.shape.size, shape.shape.size.length() / 2.0]
		elif shape.shape is CapsuleShape2D:
			shape_details = "radius=%.1f, height=%.1f" % [shape.shape.radius, shape.shape.height]
		Log.info("HERO COLLISION: type=%s, %s, position=%s, collision_layer=%d, collision_mask=%d" % [shape_type, shape_details, global_position, collision_layer, collision_mask])
	else:
		Log.warn("HERO COLLISION: has NO collision shape!")

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
	WorldBounds.clamp_to_world(self, HALF_EXTENT)

func _fire_projectile() -> void:
	if not is_enabled:
		return
	var direction = _get_target_direction()
	if direction == Vector2.ZERO:
		return
	if _ammunition:
		var context := {
			"speed": projectile_speed,
			"damage": base_damage,
			"parent": get_parent(),
			"owner": self,
			"damage_type": _damage_type,
			"source": self,
		}
		_ammunition.fire(global_position, direction, context)
		return
	if projectile_scene == null:
		return
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	projectile.direction = direction
	projectile.speed = projectile_speed
	projectile.damage = base_damage
	if projectile.has_method("set"):
		if "damage_type" in projectile:
			projectile.damage_type = _damage_type
		if "damage_source" in projectile:
			projectile.damage_source = self
	get_tree().current_scene.add_child(projectile)

func _get_target_direction() -> Vector2:
	var closest_enemy = TargetFinderUtil.get_closest_target_in_group(global_position, "enemies", get_tree)
	if closest_enemy:
		return (closest_enemy.global_position - global_position).normalized()
	return Vector2.ZERO

func set_ammunition(ammunition: WeaponAmmunition) -> void:
	_ammunition = ammunition

func set_fire_interval_value(value: float) -> void:
	fire_interval = max(value, 0.05)
	if fire_timer:
		fire_timer.wait_time = fire_interval
		if not fire_timer.is_stopped():
			fire_timer.start()

func set_damage_type(damage_type: String) -> void:
	_damage_type = damage_type
	Log.debug("HeroCharacter %s damage_type=%s" % [_log_name(), damage_type])

func _report_stats_to_api_manager() -> void:
	var api = SingletonUtil.get_api_manager()
	if api == null:
		Log.warn("HeroCharacter: APIManager not available for %s" % _log_name())
		return

	# Initialize hero HP in APIManager
	api.set_hero_max_hp(max_health)
	api.set_hero_hp(max_health)

	# Report hero attributes
	api.set_hero_attribute("fire_rate", fire_interval)
	api.set_hero_attribute("projectile_speed", projectile_speed)

	Log.info("HeroCharacter: Reported stats to APIManager (max_hp=%d, fire_rate=%.2f, projectile_speed=%.0f)" % [
		max_health, fire_interval, projectile_speed
	])
