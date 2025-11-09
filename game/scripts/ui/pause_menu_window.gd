extends "res://scripts/ui/game_window.gd"

class_name PauseMenuWindow

const Log = preload("res://scripts/utils/log_helper.gd")

@onready var _title: Label = $Panel/VBox/Title
@onready var _resume_button: Button = $Panel/VBox/ResumeButton
@onready var _restart_button: Button = $Panel/VBox/RestartButton
@onready var _exit_button: Button = $Panel/VBox/ExitButton

var _is_game_over := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	super._ready()
	_resume_button.pressed.connect(_on_resume_pressed)
	_restart_button.pressed.connect(_on_restart_pressed)
	_exit_button.pressed.connect(_on_exit_pressed)

func set_game_over_mode(game_over: bool) -> void:
	_is_game_over = game_over
	if _resume_button:
		_resume_button.visible = not game_over
	if _title:
		_title.text = "Game Over" if game_over else "Paused"

func on_show() -> void:
	var controller = _get_controller()
	if controller:
		controller.pause_game()

func on_hide() -> void:
	# Reset game over mode when window closes
	if _is_game_over:
		set_game_over_mode(false)
	var controller = _get_controller()
	if controller:
		controller.resume_game()

func _on_resume_pressed() -> void:
	if _is_game_over:
		Log.warn("PauseMenu: resume blocked - game is over")
		return
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
