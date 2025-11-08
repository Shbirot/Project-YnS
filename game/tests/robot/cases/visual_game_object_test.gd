extends "res://tests/robot/logic_test_case.gd"

const VisualGameObject = preload("res://scripts/core/visual_game_object.gd")

func get_name() -> String:
	return "VisualGameObject"

func run_case() -> void:
	var obj = VisualGameObject.new()
	obj.display_name = "TestObject"
	obj._ready()
	obj.set_enabled(false)
	assert_true(obj.visible == false, "Visibility follows enabled state")
	obj.set_enabled(true)
	assert_true(obj.visible == true, "Visibility restored")
	log_summary("Toggled VisualGameObject enable state to verify the helper keeps visibility in sync with the logical flag.")
