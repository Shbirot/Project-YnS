# 010 - AI Controller Modularization

## Goal  
Extract enemy AI into modular controllers.

## Why  
Chase/shoot/patrol logic currently duplicated across enemies.

## Steps  
1. AIControllerBase.gd
2. Implement:
   - ChaseAI
   - RangedAI
   - BossAI
3. EnemyBase uses:
   ```
   ai_controller.update(delta)
   ```

## Performance Notes  
- Less duplicated logic = more cache-efficient.
- AI decisions can be simplified.

## DebugUtils  
- Trace AI decisions:
  ```
  DebugUtils.trace("AI action", {...})
  ```

## Tests  
- Each AI type behaves correctly.
