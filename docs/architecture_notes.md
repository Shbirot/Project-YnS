# Architecture Notes

## Current Runtime Layout
- **Autoloads**: `GameConfig`, `EventBus`, `LevelManager`, `WeaponSystem`, `EnemyPool`, `ProjectilePool`, `DamageSystem`, `GameCatalog`. Each script exposes env overrides or pooling helpers that other nodes access via `SingletonUtil`.
- **Main scene**: `levels/main.tscn` instantiates `world_root.gd`, which wires the hero, spawner, XP collector, HUD, and camera stack. Autoloads broadcast lifecycle events so the HUD reacts without tight coupling.
- **Configs**: JSON and `.tres` assets live under `game/config/`; values are overridden via `.devenv` or environment variables read by `GameConfig`.

## System Traits

### Player / Hero
- **Data**: Stats driven by `StatBlock` resource and env prefixes. Mostly hard-coded weapon logic in `base_hero.gd`.
- **OOP**: Movement handled locally; damage + HP logic duplicated vs monsters. Needs ActorBase to consolidate HP/weapon inventory.

### Enemies
- **Data**: Scenes referenced via `GameCatalog` lookups, but archetypes are mostly hard-coded.
- **OOP**: `MonsterBase` handles pooling, chasing, and XP spawn; still duplicates stat handling and lacks pluggable AI/weapon slots.

### Weapons
- **Data**: `WeaponDataRework` resource holds stats. Cooldown + firing handled partly in hero and partly in `WeaponSystem`.
- **OOP**: Hero-only pipeline; enemies cannot easily reuse weapons because firing path is tightly coupled to hero scene.

### Config / Logging
- **Data-driven**: Env overrides exist yet JSON loaders have no validation or schema enforcement.
- **Logging**: Raw `print` statements scattered through subsystems; no level-based logger yet.

### Summary
- Most systems are partially data-driven but still rely on hard-coded glue and duplicated logic. Introducing ActorBase, shared weapon/ammo resources, and structured configs will allow empowered/boss archetypes and future automation.

