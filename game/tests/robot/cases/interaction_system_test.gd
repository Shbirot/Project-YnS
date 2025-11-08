extends "res://tests/robot/logic_test_case.gd"

const InteractionSystem = preload("res://scripts/systems/interaction_system.gd")

func get_name() -> String:
	return "InteractionSystem"

func run_case() -> void:
	test_handle_collectible()
	test_can_collect()
	log_summary("InteractionSystem correctly handles collectible interactions.")

func test_handle_collectible():
	var mock_collectible = _create_mock_collectible()
	var mock_actor = Node.new()
	InteractionSystem.handle_collectible(mock_collectible, mock_actor)
	assert_true(mock_collectible.effect_applied, "Collectible effect applied")
	mock_collectible.free()
	mock_actor.free()

func test_can_collect():
	var mock_collectible = _create_mock_collectible()
	var mock_actor = Node.new()
	mock_actor.add_to_group("heroes")
	assert_true(InteractionSystem.can_collect(mock_collectible, mock_actor), "Actor can collect")
	mock_collectible.is_enabled = false
	assert_true(not InteractionSystem.can_collect(mock_collectible, mock_actor), "Actor cannot collect disabled collectible")
	mock_collectible.free()
	mock_actor.free()

func _create_mock_collectible() -> Node:
	var mock = Node.new()
	mock.set_script(load("res://tests/robot/mocks/mock_collectible.gd"))
	mock.is_enabled = true
	return mock
