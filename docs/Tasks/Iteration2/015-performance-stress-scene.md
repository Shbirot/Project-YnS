# 015 - Performance Stress Scene

## Goal  
Create a standalone stress scene to benchmark improvements.

## Why  
Need consistent environment to test performance changes.

## Steps  
1. Create `stress_test.tscn`.
2. Auto-spawn 300–2000 enemies and projectiles.
3. Show:
   - FPS
   - Frame time
   - Memory
   - Enemy count

## Performance Notes  
- Enables before/after benchmarking.

## DebugUtils  
- Show FPS overlay.

## Tests  
- No crashes.
- Stable performance under load.
