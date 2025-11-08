extends Control

class_name GameWindow

@export var window_name := "window"
@export var starts_visible := false

var _controller

func _ready() -> void:
	visible = starts_visible
	_controller = _get_controller()
	if _controller:
		_controller.register_window(self)

func _exit_tree() -> void:
	if _controller:
		_controller.unregister_window(window_name)

func show_window() -> void:
	visible = true
	on_show()

func hide_window() -> void:
	visible = false
	on_hide()

func on_show() -> void:
	pass

func on_hide() -> void:
	pass

func update_window(_delta: float) -> void:
	pass

func _get_controller():
	var loop = Engine.get_main_loop()
	if loop is SceneTree:
		var root = loop.get_root()
		if root:
			return root.get_node_or_null("GameController")
	return null
