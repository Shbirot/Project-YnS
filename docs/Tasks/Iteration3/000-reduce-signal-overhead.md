# 000 - Reduce Signal Overhead

## Goal
Minimize use of Godot signals in high-frequency systems.

## Why
Signals cause allocations + dispatcher overhead when firing thousands of times.

## Steps
1. Identify high-volume events (enemy damage, projectile hit).
2. Replace signal emit with direct method calls.
3. Use event queues for batch processing.

## Performance
Up to 20–30% fewer allocations in stress tests.

## Tests
- Enemy dies -> UI updates.
- Projectiles apply damage normally.
