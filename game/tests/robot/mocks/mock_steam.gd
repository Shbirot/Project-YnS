extends Node

var _is_steam_running = false
var _steam_init_result = false
var _achievements = {}
var _stats = {}

func isSteamRunning():
	return _is_steam_running

func steamInit():
	return _steam_init_result

func getPersonaName():
	return "MockPlayer"

func setAchievement(achievement_name):
	_achievements[achievement_name] = true

func getAchievement(achievement_name):
	return _achievements.get(achievement_name, false)

func setStat(stat_name, value):
	_stats[stat_name] = value

func getStat(stat_name):
	return _stats.get(stat_name, 0)

func storeStats():
	pass

func set_steam_running(value):
	_is_steam_running = value

func set_steam_init_result(value):
	_steam_init_result = value
