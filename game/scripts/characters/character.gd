extends PhysicsEntity
class_name Character

const NodeUtil = preload("res://scripts/utils/node_util.gd")

## NOTE: Heroes no longer manage HP locally - see APIManager
## Monsters still use local HP via _current_health

signal health_changed(current, max)  # Monsters only
signal died  # Monsters only

@export var max_health := 100
@export var base_damage := 10
@export var team := "neutral"

## Animation state enumeration
enum AnimState { IDLE, WALK, ATTACK, HURT, DEATH }

## Current animation state (tracked for animated sprites)
var current_anim_state := AnimState.IDLE

## Local HP for MONSTERS only (heroes use APIManager)
var _current_health := 0

func _ready() -> void:
	# Set default properties for characters
	physics_mode = PhysicsMode.KINEMATIC
	collision_mode = CollisionMode.PHYSICAL
	movement_mode = MovementMode.VELOCITY
	render_tier = RenderTier.CRITICAL

	# Store stats in dictionary
	stats["max_health"] = max_health
	stats["base_damage"] = base_damage
	stats["team"] = team

	super._ready()

	# Only initialize local HP for monsters (heroes use APIManager)
	if not is_in_group("heroes"):
		_current_health = max_health
		health_changed.emit(_current_health, max_health)

## Apply damage (MONSTERS ONLY - heroes go through APIManager)
func apply_damage(amount: int, source = null) -> void:
	if is_in_group("heroes"):
		Log.warn("Character.apply_damage called on hero - should use APIManager!")
		return

	var source_name = NodeUtil.get_display_name(source)
	if amount <= 0:
		Log.warn("DAMAGE REJECTED: %s received zero/negative damage (%d) from %s" % [display_name, amount, source_name])
		return
	if not is_enabled:
		Log.warn("DAMAGE REJECTED: %s is disabled, cannot take damage from %s" % [display_name, source_name])
		return

	var old_hp = _current_health
	_current_health = max(_current_health - amount, 0)
	health_changed.emit(_current_health, max_health)

	Log.info("DAMAGE APPLIED: %s took %d damage (%d->%d) from %s" % [
		display_name, amount, old_hp, _current_health, source_name
	])

	# Play hurt animation if using animated sprites
	if _current_health > 0:
		play_hurt_animation()

	if _current_health <= 0:
		_emit_death(source)

## Heal (MONSTERS ONLY - heroes use APIManager)
func heal(amount: int) -> void:
	if is_in_group("heroes"):
		Log.warn("Character.heal called on hero - should use APIManager!")
		return

	_current_health = clamp(_current_health + amount, 0, max_health)
	health_changed.emit(_current_health, max_health)

func _emit_death(source):
	var source_name = NodeUtil.get_display_name(source)
	Log.warn("%s died (source=%s)" % [display_name, source_name])
	play_death_animation()
	died.emit()
	set_enabled(false)

## Update animation state based on character movement and actions
## Call this from _physics_process in derived classes (HeroCharacter, MonsterCharacter)
func _update_animation_state() -> void:
	if not use_animated_sprite:
		return

	var new_state := AnimState.IDLE

	# Determine state based on velocity
	if velocity.length() > 10.0:
		new_state = AnimState.WALK
	else:
		new_state = AnimState.IDLE

	# Only update if state changed
	if new_state != current_anim_state:
		current_anim_state = new_state
		_play_state_animation(new_state)

## Play the animation corresponding to the given state
func _play_state_animation(state: AnimState) -> void:
	match state:
		AnimState.IDLE:
			play_animation("idle")
		AnimState.WALK:
			play_animation("walk")
		AnimState.ATTACK:
			play_animation("attack", true)
		AnimState.HURT:
			play_animation("hurt", true)
		AnimState.DEATH:
			play_animation("death", true)

## Trigger attack animation (call this when character attacks)
func play_attack_animation() -> void:
	if use_animated_sprite and animated_sprite:
		current_anim_state = AnimState.ATTACK
		_play_state_animation(AnimState.ATTACK)

## Trigger hurt animation (call this when character takes damage)
func play_hurt_animation() -> void:
	if use_animated_sprite and animated_sprite:
		current_anim_state = AnimState.HURT
		_play_state_animation(AnimState.HURT)

## Trigger death animation (call this when character dies)
func play_death_animation() -> void:
	if use_animated_sprite and animated_sprite:
		current_anim_state = AnimState.DEATH
		_play_state_animation(AnimState.DEATH)
