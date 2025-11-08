extends RefCounted
class_name MockFactory

static func create_damageable() -> Node:
	var mock = Node.new()
	mock.set_script(load("res://tests/robot/mocks/mock_damageable.gd"))
	return mock

static func create_collectible() -> Node:
	var mock = Node.new()
	mock.set_script(load("res://tests/robot/mocks/mock_collectible.gd"))
	mock.is_enabled = true
	return mock

static func create_game_controller() -> Node:
	var mock = Node.new()
	mock.name = "GameController"
	mock.set_script(load("res://tests/robot/mocks/mock_game_controller.gd"))
	return mock
