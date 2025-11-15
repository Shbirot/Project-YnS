# Nightfall Survivor — Prototype Build

This branch is a clean Godot 4.5 prototype aimed at a Steam/PC release. The legacy hierarchy, factories, and mobile/Android tooling have been removed so the repo only contains the pieces that matter for rapid iteration: a hero prefab, a minimal enemy stack, XP pickups, a wave spawner, and the automation hooks that keep the loop testable.

## Project layout

```
game/
├── src/
│   ├── autoload/          # GameConfig, EventBus, LevelManager, DamageSystem…
│   ├── features/          # Player, enemy, items, projectiles, weapons, spawner, camera
│   ├── levels/            # WorldRoot + main scene
│   ├── shared/
│   │   ├── assets/
│   │   │   ├── frames/    # SpriteFrames resources
│   │   │   └── poc/       # Proof-of-concept textures (hero, coin, etc.)
│   │   └── scripts/       # SingletonUtil + helpers
│   └── ui/                # HUD scene + script
├── tests/
│   ├── sim/               # Manual launcher + autoplay CLI drivers
│   └── robot/             # Logic-focused Robot cases
├── config/                # Wave JSON and future data files
├── assets_raw/            # Reserved for non-imported source art
└── default_env.tres
scripts/
├── devtool.py             # Interactive CLI for editor/sim/test flows
└── run_tests.sh           # Robot Framework runner (wraps Godot logic tests)
```

`game/src/` is feature-oriented: each gameplay module owns its scene, script, and supporting data, keeping references localized and making it easier to grow the prototype. `src/shared/assets/poc/` carries the placeholder sprites + props while `src/shared/assets/frames/` holds the SpriteFrames resources that wire them up. Autoload singletons live in `src/autoload/` and expose world state to features.

## Running the game

1. Install Godot 4.5 (a binary lives under `tools/godot/godot4`). Export `GODOT_BIN` if you use a different build.
2. Run `python scripts/devtool.py` and pick option `1` to launch the editor, or launch Godot manually and open the `game/` folder.
3. The run scene is already set to `res://src/levels/main.tscn`. Press play to roam the arena: the hero auto-fires, XP orbs magnetize when you get close, and `LevelManager` tracks XP/level for the HUD. To test new spritesheets, drop them under `game/src/shared/assets/poc/` (keeping the .import files beside the PNG/SVG) and edit `res://src/shared/assets/frames/poc_hero_frames.tres`.

## QA & simulation

`python scripts/devtool.py` is the entry point for everything:

1. **Launch editor** – opens Godot attached to the prototype scene.
2. **Manual simulation** – runs the arena and keeps it open until you close it.
3. **Timed simulation** – same arena, but prompts for an auto-exit duration so you can script 15s/30s runs.
4. **Autoplay simulation** – drives the hero via JSON configs (`res://tests/sim/autoplay/autoplay_basic.json`).
5. **Robot tests** – shells into `./scripts/run_tests.sh`.
6. **Editor smoke** – `--editor --headless --quit` to verify modules load (also runs automatically before manual/timed sims).
7. **Deploy placeholder** – stub for future build automation.
8. **Aseprite placeholder** – hook to launch asset tooling later.
9. **.devenv editor** – tweak environment variables the devtool reads.

Autoplay configs define how the virtual player moves and for how long. Duplicate `autoplay_basic.json` to add longer or more complex runs; the agent reports XP, enemy kills, and simulated time. Option 5 shows the editor’s log in-line and saves it to `smoke.log` so you can confirm there are no hidden script errors.

## Robot tests

The old 40+ case suite has been replaced with three smoke-style specs in `game/tests/robot/cases`:

- `world_boot_test.gd` instantiates the main scene and asserts Hero/HUD/Spawner nodes exist.
- `weapon_fire_test.gd` ensures the hero fires a projectile into the current scene.
- `xp_collection_test.gd` validates that XP orbs notify LevelManager through EventBus.
- `projectile_pool_test.gd` confirms projectile pooling reuses the same instance instead of allocating new nodes.

They run quickly, exercise the same scripts as the live game, and keep `./scripts/run_tests.sh` relevant for CI.

## Combat & weapons

Enemies now derive from `Monster` (`res://src/features/enemy/monster.gd`), a base class that plugs in animation profiles, lightweight hero tracking, and health management. Specific behaviours such as XP drops or contact damage are layered in subclasses (see `basic_enemy.gd`). The spawner tags each enemy with its wave index, emits `wave_spawned`/`wave_completed`, and listens for `enemy_died(enemy, source)` so HUD or progression logic can react without tight coupling.

The hero exports `initial_weapons` and `weapon_unlock_order`, and the new `WeaponSystem` autoload ticks `WeaponDataRework` resources every frame. When a weapon’s cooldown reaches zero, the autoload asks the hero to `fire_weapon()`—projectiles still spawn through the hero so offsets, pooling, and targeting stay centralized. Level-up events simply unlock the next resource in the queue, making it trivial to add additional weapons: drop the `.tres` file in `src/features/weapons/`, list it in the hero scene, and the rest of the pipeline picks it up automatically.

## Animation profiles & spritesheets

Every animated entity (hero, enemies, future NPCs) now points to an `AnimationProfile` resource (`res://src/shared/scripts/animation_profile.gd`). A profile references a SpriteFrames `.tres`, declares per-animation base speeds, and exposes an `env_prefix`. At runtime the consuming script duplicates the SpriteFrames, applies any per-animation env overrides, and assigns the result to its `AnimatedSprite2D`. To add a new spritesheet:

1. Drop the PNG/SVG atlas into `game/src/shared/assets/poc/<category>/` (or another shared asset folder) so Godot imports it.
2. Create a SpriteFrames `.tres` referencing the sheet (see `src/shared/assets/frames/poc_hero_frames.tres` for layout).
3. Create an `AnimationProfile` `.tres` beside the feature (e.g., `src/features/player/hero_animation_profile.tres`) and set `sprite_frames`, `default_animation`, `animation_speeds`, and `env_prefix`.
4. Assign the profile via the scene’s exported `animation_profile` property. From that point you can tune frame pacing via env vars like `NF_ANIM_HERO_WALK_SPEED` without editing the resource again.

## Autoloads

| Singleton      | Purpose                                   |
| -------------- | ----------------------------------------- |
| `GameConfig`   | Environment flags + shared world bounds.  |
| `EventBus`     | Signals linking hero/enemy/HUD systems.   |
| `GameCatalog`  | Simple lookup for hero/enemy/projectile scenes. |
| `LevelManager` | Tracks XP/level and emits HUD-friendly signals. |
| `DamageSystem` | Applies hero/enemy damage and broadcasts hits. |
| `ProjectilePool` | Recycles projectile instances for performance. |
| `WeaponSystem` | Manages hero loadouts, cooldowns, and unlocks. |

This is the entire runtime surface now—no ObjectFactory, BootLoader, or PersistenceManager remain. Extend these singletons when you add new systems so both the editor run and the automated simulators behave the same.

See `docs/poc_assets.md` for guidance on the placeholder asset pack and the Aseprite iteration workflow.

## Environment overrides

Most gameplay defaults can be overridden via environment variables (and therefore via the `.devenv` file the devtool sources). Common keys:

| Key | Purpose |
| --- | --- |
| `NF_HERO_MAX_SPEED`, `NF_HERO_ACCELERATION`, `NF_HERO_FRICTION` | Override hero movement stats. |
| `NF_HERO_MAX_HEALTH` | Adjust hero health pool. |
| `NF_HERO_PROJECTILE_OFFSET` | Fine-tune where projectiles spawn relative to the hero. |
| `NF_ENEMY_MAX_HEALTH`, `NF_ENEMY_MOVE_SPEED`, `NF_ENEMY_ACCELERATION`, `NF_ENEMY_FRICTION`, `NF_ENEMY_DAMAGE` | Enemy tuning knobs. |
| `NF_XP_VALUE`, `NF_XP_MAGNET_SPEED`, `NF_XP_PICKUP_RADIUS` | XP orb behavior. |
| `NF_WAVE_CONFIG_PATH` | Alternate wave JSON file. |
| `NF_LEVEL_STARTING_LEVEL` | Starting level for the `LevelManager`. |
| `NF_WEAPON_BASIC_WAND_FIRE_INTERVAL`, `..._DAMAGE`, `..._PROJECTILE_SPEED` | Weapon-specific tuning (prefix matches the weapon’s `env_prefix`). |
| `NF_ANIM_HERO_*_SPEED`, `NF_ANIM_ENEMY_*_SPEED` | Per-animation SpriteFrames speed overrides driven by `AnimationProfile` resources. |
| `NF_ANIM_HERO_SPEED_SCALE`, `NF_ANIM_ENEMY_SPEED_SCALE` | Optional overall speed-scale applied to AnimatedSprite2D nodes. |

Set these in `.devenv` (via devtool option 9) or export them in your shell before launching Godot. Omitted keys fall back to the exported defaults in the scene/resource files.
