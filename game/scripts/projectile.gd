extends Area2D

@export var speed := 700.0
@export var lifetime := 2.5
@export var damage := 10
var direction := Vector2.UP

@onready var life_timer : Timer = $LifeTimer

func _ready() -> void:
	life_timer.wait_time = lifetime
	life_timer.timeout.connect(queue_free)
	life_timer.start()
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position += direction.normalized() * speed * delta

func _on_body_entered(body: Node) -> void:
	if body.has_method("apply_damage"):
		body.apply_damage(damage)
	queue_free()
