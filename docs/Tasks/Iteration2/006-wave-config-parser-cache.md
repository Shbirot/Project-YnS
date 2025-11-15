# 006 - Wave Config Parser Cache

## Goal  
Cache parsed wave configs so they aren't reloaded every wave spawn.

## Why  
Wave JSON/TRES loads create disk I/O and GC.

## Steps  
1. Create `WaveConfigCache.gd`.
2. On first load: parse file → store in dictionary.
3. Spawner uses cached version.

## Performance Notes  
- Eliminates repeated parsing.
- Faster wave spawning under stress tests.

## DebugUtils  
- Log:
  ```
  DebugUtils.debug("Wave cache hit", {...})
  ```

## Tests  
- Cache reused.
- No repeat loads.
