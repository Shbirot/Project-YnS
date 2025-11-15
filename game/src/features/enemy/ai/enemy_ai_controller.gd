extends Resource
class_name EnemyAIController

func get_move_direction(monster: MonsterBase, hero: ActorBase) -> Vector2:
	return Vector2.ZERO

func should_attack(_monster: MonsterBase, _hero: ActorBase) -> bool:
	return true
