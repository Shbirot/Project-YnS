# 014 - Configurable Movement Profile

## Goal  
Move speed, acceleration, friction into `.tres` movement profiles.

## Why  
Currently hard-coded in ActorBase.

## Steps  
1. Create `MovementProfile.gd` Resource.
2. ActorBase loads in `_ready()`:
   ```
   apply_movement_profile(profile)
   ```

## Performance Notes  
- No runtime ENV reads.
- Consistent movement across archetypes.

## DebugUtils  
- Log loaded profile.

## Tests  
- Movement reacts to `.tres` changes.
