extends CharacterBody2D

## Base node for every visible entity in the world (characters, pickups, props, etc.).
## Provides identity, enable/disable lifecycle hooks, and sprite management.
class_name VisualGameObject

@export var object_id : String = ""
@export var display_name : String = "Object"
@export var sprite_texture : Texture2D
@export var is_enabled := true

@onready var sprite : Sprite2D = _find_or_create_sprite()

func _ready() -> void:
	_update_enabled_state(is_enabled)
	if sprite_texture:
		_apply_texture(sprite_texture)
	Logger.debug("VisualGameObject ready: %s" % display_name)

func _find_or_create_sprite() -> Sprite2D:
	var existing = get_node_or_null("Sprite2D")
	if existing:
		return existing
	var node = Sprite2D.new()
	node.name = "Sprite2D"
	add_child(node)
	return node

func _apply_texture(texture: Texture2D) -> void:
	sprite.texture = texture

func set_enabled(value: bool) -> void:
	is_enabled = value
	_update_enabled_state(value)

func _update_enabled_state(value: bool) -> void:
	visible = value
	set_process(value)
	set_physics_process(value)

func set_sprite_from_path(path: String) -> void:
	var tex = load(path)
	if tex is Texture2D:
		sprite_texture = tex
		_apply_texture(tex)
	else:
		Logger.warn("Failed loading texture for %s from %s" % [display_name, path])
