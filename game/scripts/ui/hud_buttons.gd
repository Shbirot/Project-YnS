extends Control

const Log = preload("res://scripts/utils/log_helper.gd")

@onready var _pause_button: Button = $HBox/PauseButton
@onready var _attributes_button: Button = $HBox/AttributesButton

func _ready() -> void:
	_pause_button.pressed.connect(_on_pause_pressed)
	_attributes_button.pressed.connect(_on_attributes_pressed)

func _on_pause_pressed() -> void:
	Log.info("HUDButtons: Pause button pressed")
	var controller = _get_controller()
	if controller:
		controller.show_window("pause_menu")
	else:
		Log.warn("HUDButtons: controller missing when pausing")

func _on_attributes_pressed() -> void:
	Log.info("HUDButtons: Attributes button pressed")
	var controller = _get_controller()
	if controller:
		controller.show_window("attribute_window")
	else:
		Log.warn("HUDButtons: controller missing when showing attributes")

func _get_controller():
	var loop = Engine.get_main_loop()
	if loop is SceneTree:
		var root = loop.get_root()
		if root:
			return root.get_node_or_null("GameController")
	return null
