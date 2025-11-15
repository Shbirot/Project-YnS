# 001 - Animation State Machine Refactor

## Goal  
Convert `_update_animation()` from long if-else logic to a table-driven animation state machine.

## Why  
Current branching is expensive and hard to maintain.

## Steps  
1. Create `AnimationStateMachine.gd` Resource:
   - idle animation name
   - movement prefix
   - breathing animation
2. Animation logic becomes:
   ```
   var anim = anim_sm.compute(input_vector, velocity)
   animated_sprite.play(anim)
   ```

## Performance Notes  
- Removes repeated `sprite_frames.has_animation()` calls.
- Moves logic from runtime → resource config.

## DebugUtils  
- Log state transitions:
  ```
  DebugUtils.debug("Anim transition", {"state": state})
  ```

## Tests  
- Correct animation for idle/walk/breathe.
- Direction detection correct.
