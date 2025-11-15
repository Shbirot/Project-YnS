# 006 - Lazy Load Large Assets

## Goal
Only load large boss assets when needed.

## Why
Reduce boot time + memory footprint.

## Steps
1. Detect rarely used enemy archetypes.
2. Use ResourceLoader.load_interactive().
3. Preload only first few waves.

## Performance
Smaller initial RAM footprint.

## Tests
- Boss spawns correctly.
