# 013 - Spawn System Refactor

## Goal  
Unify spawn logic under a single `SpawnService`.

## Why  
SpawnerController and enemies duplicate spawning patterns.

## Steps  
1. Create `SpawnService.gd`.
2. Methods:
   - spawn_enemy
   - spawn_projectile
   - spawn_effect
3. Pool where appropriate.

## Performance Notes  
- Less instancing.
- Better object reuse.

## DebugUtils  
- Log spawn events:
  ```
  DebugUtils.trace("Spawn", {...})
  ```

## Tests  
- All spawns behave same as before.
