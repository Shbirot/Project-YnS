extends Character

class_name MonsterCharacter

const MovementSystem = preload("res://scripts/systems/movement_system.gd")
const CombatSystem = preload("res://scripts/systems/combat_system.gd")

@export var contact_damage := 10
@export var damage_interval := 0.8
var _damage_cooldown := 0.0
var _target : Node2D

func set_target(target: Node2D) -> void:
	_target = target

func initialize(target: Node2D) -> void:
	set_target(target)

func _physics_process(delta: float) -> void:
	if not is_enabled:
		return
	if not is_instance_valid(_target):
		velocity = Vector2.ZERO
		return
	MovementSystem.seek_target(self, _target, move_speed)
	_damage_cooldown = CombatSystem.tick_cooldown(_damage_cooldown, delta)
	if global_position.distance_to(_target.global_position) < 28:
		var applied = CombatSystem.try_contact_damage(self, _target, contact_damage, _damage_cooldown <= 0.0)
		if applied:
			_damage_cooldown = damage_interval
