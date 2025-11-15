# 004 - Optimize Stat Lookup

## Goal
Remove dictionary lookups for stats every frame.

## Why
Dictionary access cost is non-trivial.

## Steps
1. Load stats_profile fields into local vars on spawn.
2. Replace get_stat calls with direct values.

## Performance
Reduced CPU in hot loops.

## Tests
- Stats match profile.
