# 005 - Enemy Archetype Resource

## Goal  
Move all enemy stats and config into `EnemyArchetype.tres`.

## Why  
Enemy scripts have duplicated values and hard-coded parameters.

## Steps  
1. Create Resource `EnemyArchetype.gd`.
2. Fields:
   - stats_profile
   - movement_profile
   - ai_type
   - animations
3. Enemy loads during `_ready()`:
   ```
   apply_archetype(archetype)
   ```

## Performance Notes  
- No repeated stats parsing.
- Early resource loading.

## DebugUtils  
- Log archetype load:
  ```
  DebugUtils.info("Archetype loaded", {"type": archetype.name})
  ```

## Tests  
- Each enemy loads correct stats.
