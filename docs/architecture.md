# Nightfall Survivor Architecture

Nightfall Survivor is a Godot 4 project structured for fast iteration on mobile-first, top-down arena gameplay. This document summarizes the moving pieces.

## Engine layout

```
game/
├── assets/            Placeholder sprites, icons, UI mockups
├── autoload/          Global singletons (GameConfig, future managers)
├── scenes/            Instanced scenes for gameplay and UI
├── scripts/           GDScript source attached to scenes
├── default_env.tres   Shared environment/lighting profile
└── export_presets.cfg Godot export definitions
```

### Core scenes
- `Main` (`scenes/main.tscn`): Root world composition, wires hero ↔ HUD ↔ spawner.
- `Player` (`scenes/player.tscn`): A `HeroCharacter` instance (inherits the shared character stack) that supports touch + keyboard input and auto-firing projectiles.
- `EnemySpawner` (`scenes/enemy_spawner.tscn`): Spawns monsters outside the camera, scaling spawn cadence via environment + JSON config.
- `HUD` (`scenes/hud.tscn`): Minimal CanvasLayer showing timer, HP, and status text.

### Object hierarchy

Every in-world entity derives (directly or indirectly) from `VisualGameObject` (`scripts/core/visual_game_object.gd`), which wraps a `CharacterBody2D` with identity, sprite, and enable/disable helpers. On top of that:

- `MovableGameObject` adds velocity helpers (`move_dir`, `face_point`).
- `InteractableObject` / `NonInteractableObject` allow semantic separation for pickups vs. props.
- `Character` (`scripts/characters/character.gd`) layers HP/damage/signals common to all living units.
- `HeroCharacter` / `MonsterCharacter` specialize player input or hostile AI.
- Leaf scripts (`scripts/hero.gd`, `scripts/enemy.gd`) inherit from the branch they need and fetch tunables from `ConfigManager`.

Future actors (bosses, chests, buffs, coins, etc.) should extend the most specific ancestor needed so they inherit logging, sprite handling, and configuration hooks automatically.

### Systems
-
`GameConfig` (`autoload/game_config.gd`): Reads the active environment from `NIGHTFALL_ENV`. Downstream systems ask it for tunables (spawn rate, xp multipliers, analytics toggles) so balancing differences between dev/stage/prod never require code edits.
-
`ConfigManager` (`autoload/config_manager.gd`): Loads `res://config/settings/defaults.json` and merges in per-environment overrides (`dev.json`, `stage.json`, `prod.json`). Provides `get_value("hero.fire_interval")` style lookups for any gameplay system.
-
`Logger` (`autoload/logger.gd`): Writes `[timestamp][LEVEL] message` to stdout and `user://logs/nightfall_YYYYMMDD.log`, rotating daily but keeping the same file across restarts within that day.
-
`HeroCharacter` auto-targeting: Samples the nearest member of the `enemies` group and keeps firing projectiles at cadence defined in config.
-
`Enemy` navigation: Simple seek behavior toward the hero with configurable contact damage. Replace with NavigationServer2D once arena layouts solidify.
-
`EnemySpawner`: Randomizes polar spawn points around the hero (`spawn_radius`) and enforces a population cap. Hook balancing knobs here for future scaling or wave logic. In debug builds you can spawn enemies manually (see `scripts/main.gd`).
-
`HUD`: Passive view that consumes signals for HP/time/status updates. Add new UI widgets (XP bar, weapon selection) here without touching `Main` once their own signals exist.
-
`MovementSystem` (`scripts/systems/movement_system.gd`): Static helpers that operate directly on `CharacterBody2D` instances, keeping movement math centralized and cache-friendly even with large crowds.
-
`CombatSystem` (`scripts/systems/combat_system.gd`): Lightweight routines for ticking damage cooldowns and applying hits/contact damage without scattering branching logic across every unit.
-
`InteractionSystem` + `Collectible` (`scripts/systems/interaction_system.gd`, `scripts/interactables/collectible.gd`): Governs how pickups/powerups detect heroes and apply effects. Extending `Collectible` keeps interaction costs low because Area2D overlap checks are handled by Godot’s physics server and the per-frame logic stays minimal; debug hotkeys (`E` for enemies, `R` for coins) help test these flows without cluttering release builds.
-
`PersistenceManager` (`autoload/persistence_manager.gd`): Snapshots essential runtime state (hero position, currency, health metadata) every 30 seconds to `user://persistence.json` and reapplies it on startup—this keeps editor tweaks or dev/test sessions consistent and lays the groundwork for future player progression saves.

## Environments and pipelines

Each export preset carries a `custom_feature` (`env.dev`, `env.stage`, `env.prod`). `GameConfig` maps that tag to a set of tunables (spawn cadence, analytics flags). Godot’s CLI exports reference those presets, so CI/CD can build dev/stage/prod artifacts with identical code but different behavior.

External automation hooks live under `scripts/` and `.github/workflows/`. They parameterize the environment through `NIGHTFALL_ENV` for desktop runs and rely on preset feature tags for mobile builds.

## Next steps

1. Flesh out combat loops (e.g., weapons, upgrades) by adding dedicated systems under `game/scripts/systems/` and autoloading singletons when state becomes global.
2. Replace placeholder art with production assets and wire them into dedicated import presets.
3. Layer services (analytics, backend telemetry) behind `GameConfig` flags so prod-only code paths remain dormant elsewhere.
