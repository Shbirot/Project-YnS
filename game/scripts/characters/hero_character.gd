extends Character

class_name HeroCharacter

const MovementSystem = preload("res://scripts/systems/movement_system.gd")
const WorldBounds = preload("res://scripts/systems/world_bounds.gd")
const WeaponAmmunition = preload("res://scripts/weapons/ammunition_base.gd")
const SceneTreeUtil = preload("res://scripts/utils/scene_tree_util.gd")
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
var _attributes_manager
var _attributes_warned := false

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
	_attributes_manager = SceneTreeUtil.get_manager("attributes_manager")
	_sync_attributes()
	set_process_unhandled_input(true)
	set_fire_interval_value(fire_interval)
	fire_timer.timeout.connect(_fire_projectile)
	fire_timer.start()
	Log.info("HeroCharacter ready: %s" % _log_name())

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
	_sync_attributes()

func set_damage_type(damage_type: String) -> void:
	_damage_type = damage_type
	Log.debug("HeroCharacter %s damage_type=%s" % [_log_name(), damage_type])

func _sync_attributes() -> void:
	if _attributes_manager == null:
		_attributes_manager = SceneTreeUtil.get_manager("attributes_manager")
		if _attributes_manager == null:
			if not _attributes_warned:
				Log.warn("HeroCharacter: attributes manager not set for %s" % _log_name())
				_attributes_warned = true
			return
	_attributes_manager.set_attribute("hp", max_health)
	_attributes_manager.set_attribute("fire_rate", fire_interval)
	_attributes_manager.set_attribute("projectile_speed", projectile_speed)
	_attributes_warned = false
