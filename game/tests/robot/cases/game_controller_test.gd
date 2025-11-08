extends "res://tests/robot/logic_test_case.gd"

const GameController = preload("res://scripts/core/game_controller.gd")

func get_name() -> String:
	return "GameController"

func run_case() -> void:
	var controller = GameController.new()
	var tree = get_tree_ref()
	if tree:
		tree.root.add_child(controller)
	controller.initialize()
	assert_true(controller.is_initialized(), "controller initialized")
	controller.register_window(_make_window("test_window"))
	controller.show_window("test_window")
	assert_true(controller._windows.has("test_window"), "window registered")
	controller.hide_window("test_window")
	controller.unregister_window("test_window")
	log_summary("Initialized a fresh GameController and verified window registration/show/hide lifecycle works as expected.")
	controller.queue_free()

func _make_window(name: String):
	var BaseWindow = preload("res://scripts/ui/game_window.gd")
	var window = BaseWindow.new()
	window.window_name = name
	return window
