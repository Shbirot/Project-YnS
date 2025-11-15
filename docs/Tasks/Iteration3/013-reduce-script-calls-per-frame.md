# 013 - Reduce Script Calls Per Frame

## Goal
Remove unnecessary per-frame _process calls.

## Why
Every script call costs overhead.

## Steps
1. Disable _process where idle.
2. Use timers or signals for infrequent updates.

## Performance
Lower frame overhead.

## Tests
- No behavior loss.
