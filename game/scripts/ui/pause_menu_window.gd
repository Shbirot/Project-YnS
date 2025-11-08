extends "res://scripts/ui/game_window.gd"

class_name PauseMenuWindow

const Log = preload("res://scripts/utils/log_helper.gd")

@onready var _resume_button: Button = $Panel/VBox/ResumeButton
@onready var _restart_button: Button = $Panel/VBox/RestartButton
@onready var _exit_button: Button = $Panel/VBox/ExitButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	super._ready()
	_resume_button.pressed.connect(_on_resume_pressed)
	_restart_button.pressed.connect(_on_restart_pressed)
	_exit_button.pressed.connect(_on_exit_pressed)

func on_show() -> void:
	var controller = _get_controller()
	if controller:
		controller.pause_game()

func on_hide() -> void:
	var controller = _get_controller()
	if controller:
		controller.resume_game()

func _on_resume_pressed() -> void:
	Log.info("PauseMenu: resume pressed")
	hide_window()

func _on_restart_pressed() -> void:
	var controller = _get_controller()
	if controller:
		Log.info("PauseMenu: restart requested")
		controller.reset_game()
	hide_window()

func _on_exit_pressed() -> void:
	Log.info("PauseMenu: exit pressed")
	get_tree().quit()
