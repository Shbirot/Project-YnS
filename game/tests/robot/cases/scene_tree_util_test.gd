extends "res://tests/robot/logic_test_case.gd"

const SceneTreeUtil = preload("res://scripts/utils/scene_tree_util.gd")
const MockFactory = preload("res://tests/robot/mocks/mock_factory.gd")

func get_name() -> String:
	return "SceneTreeUtil"

func run_case() -> void:
	var mock_logger = Node.new()
	mock_logger.name = "Logger"
	var mock_controller = MockFactory.create_game_controller()
	var root = get_tree_ref().get_root()
	root.add_child(mock_logger)
	root.add_child(mock_controller)

	test_get_root()
	test_get_autoload()
	test_get_manager()

	root.remove_child(mock_logger)
	root.remove_child(mock_controller)
	mock_logger.queue_free()
	mock_controller.queue_free()
	log_summary("SceneTreeUtil correctly retrieves the root node, autoload singletons, and managers.")

func test_get_root():
	var root = SceneTreeUtil.get_root()
	assert_true(root != null, "Get root node")
	assert_true(root is Window, "Root node is a Window")

func test_get_autoload():
	var logger = SceneTreeUtil.get_autoload("Logger")
	assert_true(logger != null, "Get Logger autoload")
	var non_existent = SceneTreeUtil.get_autoload("NonExistent")
	assert_true(non_existent == null, "Get non-existent autoload returns null")

func test_get_manager():
	var attributes_manager = SceneTreeUtil.get_manager("attributes_manager")
	assert_true(attributes_manager != null, "Get attributes manager")
	var non_existent = SceneTreeUtil.get_manager("non_existent_manager")
	assert_true(non_existent == null, "Get non-existent manager returns null")
