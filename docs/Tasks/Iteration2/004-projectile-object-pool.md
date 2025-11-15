# 004 - Projectile Object Pool

## Goal  
Replace projectile instantiate/free loop with an object pool.

## Why  
Projectiles are the largest source of GC stutter and allocations.

## Steps  
1. Create `ProjectilePool.gd`.
2. Pre-allocate N instances per projectile type.
3. `acquire()` → returns an inactive projectile.
4. `release()` → resets projectile and stores it.

## Performance Notes  
- Reduces memory fragmentation.
- Stable FPS during high fire rates.

## DebugUtils  
- Print:
  ```
  DebugUtils.debug("Projectile pool usage", {...})
  ```

## Tests  
- Pool reuses projectiles.
- No uncontrolled expansion.
