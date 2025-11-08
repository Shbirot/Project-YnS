extends "res://tests/robot/logic_test_case.gd"

const Character = preload("res://scripts/characters/character.gd")

func get_name() -> String:
	return "Character"

func run_case() -> void:
	var character = Character.new()
	character.max_health = 100
	character._current_health = 100

	test_apply_damage(character)
	test_heal(character)

	character.free()
	log_summary("Character correctly applies damage and heals.")

func test_apply_damage(character):
	character.apply_damage(10)
	assert_equal(character._current_health, 90, "Apply damage")
	character.apply_damage(-10)
	assert_equal(character._current_health, 90, "Apply negative damage does nothing")
	character.apply_damage(100)
	assert_equal(character._current_health, 0, "Damage to zero")

func test_heal(character):
	character._current_health = 50
	character.heal(10)
	assert_equal(character._current_health, 60, "Heal")
	character.heal(100)
	assert_equal(character._current_health, 100, "Heal to max")
