extends "res://tests/robot/logic_test_case.gd"

const MockSteam = preload("res://tests/robot/mocks/mock_steam.gd")

func run_case():
	# --- Setup ---
	var scene_tree = Engine.get_main_loop()
	var steam_manager = scene_tree.root.get_node("SteamManager")
	var mock_steam = MockSteam.new()
	steam_manager.SteamAPI = mock_steam

	# --- Test Cases ---
	# Test successful initialization
	mock_steam.set_steam_running(true)
	mock_steam.set_steam_init_result(true)
	steam_manager._ready()
	assert_true(steam_manager.is_steam_initialized(), "Steam should be initialized")

	# Test initialization fails if Steam is not running
	mock_steam.set_steam_running(false)
	steam_manager._ready()
	assert_false(steam_manager.is_steam_initialized(), "Steam should not be initialized if not running")

	# Test initialization fails if steamInit() returns false
	mock_steam.set_steam_running(true)
	mock_steam.set_steam_init_result(false)
	steam_manager._ready()
	assert_false(steam_manager.is_steam_initialized(), "Steam should not be initialized if init fails")

	# Test get_player_name
	mock_steam.set_steam_running(true)
	mock_steam.set_steam_init_result(true)
	steam_manager._ready()
	assert_eq(steam_manager.get_player_name(), "MockPlayer", "Should return the mock player name")

	# Test unlock_achievement
	steam_manager.unlock_achievement("test_achievement")
	assert_true(mock_steam.get_achievement("test_achievement"), "The achievement should be unlocked")

	# Test set_and_get_stat
	steam_manager.set_stat("test_stat", 42)
	assert_eq(steam_manager.get_stat("test_stat"), 42, "The stat should be set and retrieved correctly")

	# --- Teardown ---
	if is_instance_valid(mock_steam):
		mock_steam.queue_free()
