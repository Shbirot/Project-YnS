extends Resource
class_name EnemyAIController

## Base AI controller for enemy behavior
## Modular AI system for chase/patrol/boss patterns

func get_move_direction(monster: MonsterBase, hero: ActorBase) -> Vector2:
	if OS.has_environment("NF_DEBUG") and OS.get_environment("NF_DEBUG") == "1":
		DebugUtils.debug_log("AI action", {"controller": get_class(), "monster": monster.name if monster else "null"})
	return Vector2.ZERO

func should_attack(_monster: MonsterBase, _hero: ActorBase) -> bool:
	return true
