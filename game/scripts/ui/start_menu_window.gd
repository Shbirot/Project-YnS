extends "res://scripts/ui/game_window.gd"

class_name StartMenuWindow

const Log = preload("res://scripts/utils/log_helper.gd")

@onready var _start_button: Button = $Panel/VBox/StartButton
@onready var _exit_button: Button = $Panel/VBox/ExitButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	super._ready()
	_start_button.pressed.connect(_on_start_pressed)
	_exit_button.pressed.connect(_on_exit_pressed)
	if starts_visible:
		_pause_game()

func _on_start_pressed() -> void:
	Log.info("StartMenu: Start button pressed, opening loadout window")
	hide_window()
	var controller = _get_controller()
	if controller:
		controller.show_window("game_setup")

func _on_exit_pressed() -> void:
	Log.info("StartMenu: Exit button pressed, quitting application")
	get_tree().quit()

func _pause_game() -> void:
	var controller = _get_controller()
	if controller:
		controller.pause_game()
