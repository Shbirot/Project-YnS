extends "res://tests/robot/logic_test_case.gd"

const GameController = preload("res://scripts/core/game_controller.gd")

func get_name() -> String:
	return "GameControllerError"

func run_case() -> void:
	var controller = GameController.new()
	var tree = get_tree_ref()
	if tree:
		tree.root.add_child(controller)
	controller.initialize()
	controller.show_window("ghost_window")
	assert_true(not controller._windows.has("ghost_window"), "Unknown window requests are ignored")
	var menu_state = controller.get_menu_state("missing_menu")
	assert_true(menu_state.is_empty(), "Missing menu state defaults to empty dictionary")
	controller.hide_window("ghost_window")
	log_summary("GameController ignored unknown windows/menus without crashing, returning an empty state for missing entries.")
	controller.queue_free()
