extends "res://tests/robot/logic_test_case.gd"

const StartMenuScene = preload("res://scenes/ui/start_menu_window.tscn")
const AttributeWindowScene = preload("res://scenes/ui/attribute_window.tscn")

class ControllerStub:
	extends Node
	var shown := []
	var paused := false
	var resumed := false

	func show_window(name):
		shown.append(name)

	func pause_game():
		paused = true

	func resume_game():
		resumed = true

func get_name() -> String:
	return "UIWindows"

func requires_ui() -> bool:
	return true

func run_case() -> void:
	var controller = ControllerStub.new()
	var start_menu = StartMenuScene.instantiate()
	start_menu._ready()
	var attr_window = AttributeWindowScene.instantiate()
	attr_window._ready()

	var root = get_tree_ref()
	var tree_root = root.root if root else null
	var original_controller
	if tree_root:
		original_controller = tree_root.get_node_or_null("GameController")
		if original_controller:
			original_controller.name = "__GameController_real"
	controller.name = "GameController"
	if tree_root:
		tree_root.add_child(controller)

	start_menu._on_start_pressed()
	assert_true("game_setup" in controller.shown, "Start menu triggered loadout window")
	attr_window.on_show()
	assert_true(controller.paused, "Attribute window pauses game")
	attr_window.on_hide()
	assert_true(controller.resumed, "Attribute window resumes game")
	log_summary("Start menu triggered the loadout window and the attribute panel paused/resumed gameplay through the controller stub.")
	start_menu.queue_free()
	attr_window.queue_free()
	if tree_root:
		tree_root.remove_child(controller)
	controller.queue_free()
	if original_controller:
		original_controller.name = "GameController"
