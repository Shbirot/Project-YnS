# 005 - Reduce Vector Normalization

## Goal
Normalize direction vectors only once.

## Why
Vector2.normalized() allocates + costs CPU.

## Steps
1. Compute input_vector once.
2. Store raw + normalized.
3. Reuse for animation, movement, aiming.

## Performance
Less math per frame.

## Tests
- Movement unchanged.
