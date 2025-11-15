# 009 - Remove Duplicate Vector Calculations

## Goal  
Cache vectors used multiple times per frame.

## Why  
Normalization and direction calculation repeated for:
- movement
- animation
- attack direction

## Steps  
1. In Hero:
   - compute input_vector once.
   - store normalized and magnitude.
2. Reuse same cached values.

## Performance Notes  
- Avoid repeated Vector2 allocations.
- Cleaner logic.

## DebugUtils  
- Log cache results when `NF_DEBUG=1`.

## Tests  
- Movement and attacking still correct.
