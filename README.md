# Nightfall Survivor — Rework Build

This branch is a clean Godot 4.5 prototype aimed at a Steam/PC release. The legacy hierarchy, factories, and mobile/Android tooling have been removed so the repo only contains the pieces that matter for rapid iteration: a hero prefab, a minimal enemy stack, XP pickups, a wave spawner, and the automation hooks that keep the loop testable.

## Project layout

```
game/
├── scenes/rework/        # WorldRoot, hero, enemy, HUD, projectile, XP orb
├── scripts/rework/       # Hero/camera/spawner/enemy/UI systems
├── autoload/             # GameConfig, EventBus, LevelManager, ReworkCatalog, etc.
├── assets/POC_0/         # Proof-of-concept spritesheets + props
├── tests/rework/         # Autoplay agent + manual launcher scripts
└── tests/robot/          # Headless logic tests targeting the rework stack
scripts/
├── devtool.py            # Interactive CLI for editor/sim/test flows
└── run_tests.sh          # Robot Framework runner (wraps Godot logic tests)
```

Everything under `game/scenes/rework/` composes the runtime scene tree. `WorldRoot.tscn` wires the autoload singletons together (camera targets, hero spawn, spawner hooks) while `ReworkCatalog` exposes simple scene lookups for the spawner and future systems.

## Running the game

1. Install Godot 4.5 (a binary lives under `tools/godot/godot4`). Export `GODOT_BIN` if you use a different build.
2. Run `python scripts/devtool.py` and pick option `1` to launch the editor, or launch Godot manually and open the `game/` folder.
3. The run scene is already set to `res://scenes/rework/main.tscn`. Press play to roam the arena: the hero auto-fires, XP orbs magnetize when you get close, and `LevelManager` tracks XP/level for the HUD. To test new spritesheets, drop them under `game/assets/POC_0/` and edit `res://resources/rework/poc_hero_frames.tres`.

## QA & simulation

`python scripts/devtool.py` is the entry point for everything:

1. **Launch editor** – opens Godot attached to the rework scene.
2. **Manual simulation** – runs the arena and keeps it open until you close it.
3. **Timed simulation** – same arena, but prompts for an auto-exit duration so you can script 15s/30s runs.
4. **Autoplay simulation** – drives the hero via JSON configs (`tests/rework/autoplay/autoplay_basic.json`).
5. **Robot tests** – shells into `./scripts/run_tests.sh`.
6. **Editor smoke** – `--editor --headless --quit` to verify modules load (also runs automatically before manual/timed sims).
7. **Deploy placeholder** – stub for future build automation.
8. **Aseprite placeholder** – hook to launch asset tooling later.
9. **.devenv editor** – tweak environment variables the devtool reads.

Autoplay configs define how the virtual player moves and for how long. Duplicate `autoplay_basic.json` to add longer or more complex runs; the agent reports XP, enemy kills, and simulated time. Option 5 shows the editor’s log in-line and saves it to `smoke.log` so you can confirm there are no hidden script errors.

## Robot tests

The old 40+ case suite has been replaced with three smoke-style specs in `game/tests/robot/cases`:

- `world_boot_test.gd` instantiates the rework scene and asserts Hero/HUD/Spawner nodes exist.
- `weapon_fire_test.gd` ensures the hero fires a projectile into the current scene.
- `xp_collection_test.gd` validates that XP orbs notify LevelManager through EventBus.

They run quickly, exercise the same scripts as the live game, and keep `./scripts/run_tests.sh` relevant for CI.

## Autoloads

| Singleton      | Purpose                                   |
| -------------- | ----------------------------------------- |
| `GameConfig`   | Environment flags + shared world bounds.  |
| `EventBus`     | Signals linking hero/enemy/HUD systems.   |
| `ReworkCatalog`| Simple lookup for hero/enemy/projectile scenes. |
| `LevelManager` | Tracks XP/level and emits HUD-friendly signals. |

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

Set these in `.devenv` (via devtool option 9) or export them in your shell before launching Godot. Omitted keys fall back to the exported defaults in the scene/resource files.
