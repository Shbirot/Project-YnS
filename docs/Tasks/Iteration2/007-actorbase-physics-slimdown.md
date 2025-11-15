# 007 - ActorBase Physics Slimdown

## Goal  
Reduce cost of ActorBase `_physics_process`.

## Why  
This runs per actor per frame. Must be minimal.

## Steps  
1. Inline simple expressions.
2. Cache frequently used values (speed, direction).
3. Move logic not necessary for physics to `process_actor()`.

## Performance Notes  
- Lower CPU cost per actor.
- Significant boost when >200 enemies.

## DebugUtils  
- On anomalies (NaN velocity):
  ```
  DebugUtils.warn("Invalid velocity", {...})
  ```

## Tests  
- Movement unchanged.
- No jitter.
