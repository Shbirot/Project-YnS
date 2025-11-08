extends "res://tests/robot/logic_test_case.gd"

const VisualGameObject = preload("res://scripts/core/visual_game_object.gd")

func get_name() -> String:
	return "VisualGameObjectError"

func run_case() -> void:
	var obj = VisualGameObject.new()
	obj.display_name = "Test Visual"
	obj._ready()
	var original_texture = obj.sprite_texture
	obj.set_sprite_from_path("res://assets/this_does_not_exist.png")
	assert_true(obj.sprite_texture == original_texture, "Invalid sprite path does not change texture")
	log_summary("VisualGameObject ignored an invalid sprite path, leaving the previous texture untouched.")
	obj.queue_free()
