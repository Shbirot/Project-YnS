extends "res://scripts/ui/game_window.gd"

class_name AttributeWindow

const Log = preload("res://scripts/utils/log_helper.gd")

@onready var _list: ItemList = $Panel/VBox/AttributeList
@onready var _close_button: Button = $Panel/VBox/CloseButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	super._ready()
	_close_button.pressed.connect(_on_close_pressed)

func on_show() -> void:
	Log.info("AttributeWindow: opened")
	_refresh()
	var controller = _get_controller()
	if controller:
		controller.pause_game()

func on_hide() -> void:
	Log.info("AttributeWindow: closed")
	var controller = _get_controller()
	if controller:
		controller.resume_game()

func _refresh() -> void:
	_list.clear()
	var controller = _get_controller()
	if controller == null:
		Log.warn("AttributeWindow: controller missing")
		return
	# Access attributes through GameController's API (encapsulation)
	var attrs: Dictionary = controller.get_all_attributes()
	if attrs.is_empty():
		Log.warn("AttributeWindow: no attributes available")
		return
	var keys: Array = attrs.keys()
	keys.sort()
	for key in keys:
		_list.add_item("%s: %s" % [key, _format_value(attrs[key])])

func _format_value(value) -> String:
	if typeof(value) in [TYPE_FLOAT, TYPE_INT]:
		return "%0.2f" % value
	return str(value)

func _on_close_pressed() -> void:
	Log.info("AttributeWindow: close button pressed")
	hide_window()
