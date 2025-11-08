extends Node

# SteamManager - A wrapper class for the GodotSteam extension.
# This class provides a centralized point of access for all Steamworks API calls.
# It is implemented as a singleton (autoload) to be easily accessible from anywhere
# in the game's code.

# You can access this manager from any script like this:
# SteamManager.is_steam_initialized()
# SteamManager.get_player_name()

# Note: Most Steamworks functions are asynchronous and will return results via signals.
# Make sure to connect to the appropriate signals to handle the responses.


# Signal emitted when the Steamworks API has been successfully initialized.
signal steam_initialized

# Signal emitted when the Steamworks API fails to initialize.
signal steam_init_failed


var SteamAPI = null

func _ready():
	# Allow injecting a mock for testing
	if SteamAPI == null:
		if Engine.has_singleton("Steam"):
			SteamAPI = Engine.get_singleton("Steam")
		else:
			# In a test environment, the test script is responsible for injecting a mock.
			# In a real game, this means Steam isn't available.
			print("Steam singleton not found.")
			emit_signal("steam_init_failed")
			return

	if not SteamAPI.isSteamRunning():
		print("Steam is not running.")
		emit_signal("steam_init_failed")
		return

	if SteamAPI.steamInit():
		print("Steamworks API Initialized.")
		emit_signal("steam_initialized")
	else:
		print("Failed to initialize Steamworks API.")
		emit_signal("steam_init_failed")


# --- Utility Functions ---

func is_steam_initialized() -> bool:
	"""
	Checks if the Steamworks API is initialized.
	"""
	return SteamAPI != null and SteamAPI.isSteamRunning() and SteamAPI.steamInit()


func get_player_name() -> String:
	"""
	Returns the Steam username of the current player.
	"""
	if is_steam_initialized():
		return SteamAPI.getPersonaName()
	return "Player"


# --- Achievements ---

func unlock_achievement(achievement_name: String):
	"""
	Unlocks a specific achievement.
	"""
	if is_steam_initialized():
		SteamAPI.setAchievement(achievement_name)
		SteamAPI.storeStats()


func get_achievement(achievement_name: String) -> bool:
	"""
	Checks if a specific achievement has been unlocked.
	"""
	if is_steam_initialized():
		return SteamAPI.getAchievement(achievement_name)
	return false

# --- Stats ---

func set_stat(stat_name: String, value: int):
	"""
	Sets a specific integer stat.
	"""
	if is_steam_initialized():
		SteamAPI.setStat(stat_name, value)
		SteamAPI.storeStats()

func get_stat(stat_name: String) -> int:
	"""
	Gets a specific integer stat.
	"""
	if is_steam_initialized():
		return SteamAPI.getStat(stat_name)
	return 0

# Add more wrapper functions for other Steamworks features as needed (e.g., leaderboards, cloud saves, etc.)
