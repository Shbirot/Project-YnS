extends Area2D
class_name Collectible

const Log = preload("res://scripts/utils/log_helper.gd")

const InteractionSystem = preload("res://scripts/systems/interaction_system.gd")

@export var display_name := "Collectible"
@export var pickup_sound : AudioStream
var is_enabled := true

@onready var sprite : Sprite2D = $Sprite2D

func _ready() -> void:
	monitoring = true
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not is_enabled:
		return
	if InteractionSystem.can_collect(self, body):
		InteractionSystem.handle_collectible(self, body)

func apply_effect(_actor) -> void:
	Log.info("%s collected %s" % [_actor.name, display_name])
	_disable()

func _disable() -> void:
	is_enabled = false
	monitoring = false
	visible = false
	set_process(false)
