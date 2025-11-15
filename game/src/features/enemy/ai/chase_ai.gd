extends "res://src/features/enemy/ai/enemy_ai_controller.gd"
class_name EnemyChaseAI

func get_move_direction(monster: MonsterBase, hero: ActorBase) -> Vector2:
	if hero == null or monster == null:
		return Vector2.ZERO
	return (hero.global_position - monster.global_position).normalized()
