extends Collectible

class_name CoinCollectible

@export var value := 5

func apply_effect(actor) -> void:
	Logger.info("%s picked up %s (+%d)" % [actor.name, display_name, value])
	if actor.has_method("add_currency"):
		actor.add_currency(value)
	else:
		var coins = actor.get_meta("coins") if actor.has_meta("coins") else 0
		actor.set_meta("coins", coins + value)
	_disable()
