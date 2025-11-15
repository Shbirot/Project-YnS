extends "res://src/features/enemy/ai/enemy_ai_controller.gd"
class_name EnemyKiteAI

@export var preferred_distance = 200.0
@export var tolerance = 40.0

func get_move_direction(monster: MonsterBase, hero: ActorBase) -> Vector2:
	if monster == null or hero == null:
		return Vector2.ZERO
	var to_hero = hero.global_position - monster.global_position
	var dist = to_hero.length()
	if dist == 0.0:
		return Vector2.ZERO
	if dist > preferred_distance + tolerance:
		return to_hero.normalized()
	if dist < preferred_distance - tolerance:
		return -to_hero.normalized()
	return Vector2.ZERO

func should_attack(monster: MonsterBase, hero: ActorBase) -> bool:
	if monster == null or hero == null:
		return false
	var dist = monster.global_position.distance_to(hero.global_position)
	return dist <= preferred_distance + tolerance
