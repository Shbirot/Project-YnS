# 002 - Extract Health & Damage Component

## Goal  
Move health, damage, death, and revive logic from ActorBase into a standalone `HealthComponent`.

## Why  
ActorBase is overloaded and multiple classes duplicate HP logic.

## Steps  
1. Create `HealthComponent.gd`:
   - hp
   - base_max_hp
   - apply_damage
   - heal
2. ActorBase attaches HealthComponent node.
3. HealthComponent emits:
   - `died(actor)`
   - `health_changed(actor)`

## Performance Notes  
- Health calculation no longer blocking physics loop.
- Simplifies ActorBase.

## DebugUtils  
- Emit logs:
  ```
  DebugUtils.info("Damage applied", {"amount": amount})
  ```

## Tests  
- Taking damage.
- Healing.
- Death event.
