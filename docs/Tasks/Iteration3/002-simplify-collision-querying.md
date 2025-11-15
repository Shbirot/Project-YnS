# 002 - Simplify Collision Querying

## Goal
Avoid calling get_nodes_in_group("enemies") every frame.

## Why
get_nodes_in_group allocates + filters whole tree.

## Steps
1. Implement EnemyManager singleton.
2. Maintain alive enemy list.
3. Query directly instead of scanning groups.

## Performance
Large improvement with 300+ enemies.

## Tests
- Nearest enemy correct.
