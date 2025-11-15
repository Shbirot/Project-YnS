# Gameplay Loop Overview

## Current Loop
- Player input feeds the hero controller which translates WASD/arrow actions into movement.
- `WeaponSystem` ticks on the autoload bus and fires currently equipped weapons using env-tuned cooldowns.
- Enemy spawners stream monsters that chase the hero and emit damage via projectiles/melee hitboxes.
- Kills and pickups drop XP orbs; collected orbs grant levels that unlock additional weapons/bonuses.
- When HP hits zero the level manager triggers game-over UI with restart/back-to-menu controls.

### ASCII Path
```
Input → Actor (Hero) → WeaponSystem → Ammo → Enemy → XP → LevelUps → GameConfig
             ↑                                            ↓
             └────────────── EventBus / LevelManager ─────┘
```

## Simulation Observations
- Manual sim via `python scripts/devtool.py` → `2` keeps a stable pace for ~90 seconds before spawns begin to spike; FPS stays near 60 with <5% dips.
- Once ~150 enemies are alive and 200+ projectiles cycle the pools, the GC churn becomes visible; weapon fire cadence occasionally stutters but recovers quickly.

## External References

### Vampire Survivors Clone (MikadoByte series)
- Keep combat systems data-driven with Resources, not hardcoded in scenes.
- Maintain strict separation between Actor movement and Weapon firing logic to keep tick cost predictable.
- Use enemy pools + spawn tables so waves can ramp linearly/exponentially without frame drops.

### Godot 4 Architecture (GDQuest talk)
- Centralize runtime toggles in autoloads like `GameConfig` so env overrides stay consistent.
- Drive hero/enemy stats through `StatBlock` resources with env prefixes for tweakable values.
- Prefer signals and EventBus for decoupling UI/HUD updates from gameplay code.

### Godot Performance Tips (HeartBeast profiling session)
- Preload `PackedScene`s and reuse nodes (object pools) to avoid per-frame allocations.
- Keep `_process` logic short; extract expensive math out of inner loops and reuse cached vectors.
- Emit logs conditionally and disable them entirely for prod builds to avoid string churn.

