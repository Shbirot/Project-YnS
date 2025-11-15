# 003 - Poolize Enemy Spawn Effects

## Goal
Pool VFX objects.

## Why
Instancing VFX for every spawn/death = heavy GC.

## Steps
1. Global EffectPool.
2. acquire() / release() semantics.
3. Reset VFX transform & visibility only.

## Performance
Massive reduction in spikes.

## Tests
- Effects show correctly.
