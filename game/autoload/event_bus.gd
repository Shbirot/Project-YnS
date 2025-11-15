extends Node

## Lightweight signal hub that decouples gameplay systems.
## Register this file as an Autoload singleton named `EventBus`.

signal hero_spawned(hero)
signal hero_died(hero)
signal hero_health_changed(current_health, max_health)
signal hero_damaged(hero, amount, source)
signal enemy_spawned(enemy)
signal enemy_died(enemy)
signal enemy_damaged(enemy, amount, source)
signal wave_spawned(wave)
signal xp_collected(amount, world_position)
signal level_up(level)
signal projectile_fired(projectile)

func emit_safe(signal_name: StringName, args: Array = []) -> void:
	if not has_signal(signal_name):
		push_warning("EventBus missing signal: %s" % signal_name)
		return
	var call_args := [signal_name]
	call_args.append_array(args)
	Callable(self, "emit_signal").callv(call_args)
