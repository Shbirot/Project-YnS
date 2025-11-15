# 010 - Optimize Weapon Fire Loop

## Goal
Flatten fire loop + precompute values.

## Why
Weapons fire very frequently.

## Steps
1. Precompute cooldown, angle offsets, spread.
2. Inline small calculations.
3. Use lookup tables instead of match.

## Performance
Lower cost per projectile.

## Tests
- All weapons fire same pattern.
