extends Area2D

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")

@export var lifetime := 0.2
var owner_ref: Node
var damage := 0.0

func _ready() -> void:
	monitoring = true
	set_deferred("monitorable", true)
	var timer := get_tree().create_timer(lifetime)
	timer.timeout.connect(_on_lifetime_timeout)
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _on_lifetime_timeout() -> void:
	queue_free()

func _on_body_entered(body: Node) -> void:
	if body == owner_ref:
		return
	_apply_damage(body)

func _on_area_entered(area: Area2D) -> void:
	if area == owner_ref:
		return
	_apply_damage(area)

func _apply_damage(target: Node) -> void:
	var damage_system = SingletonUtil.get_damage_system()
	if damage_system:
		var proxy = self
		proxy.owner_ref = owner_ref
		proxy.damage = damage
		damage_system.apply_projectile_hit(proxy, target)
	queue_free()
