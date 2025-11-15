# Repository Guidelines

## Project Structure & Module Organization
`game/` is the Godot project root. Runtime code now lives under `game/src/`: `autoload/` hosts GameConfig/EventBus/LevelManager/DamageSystem/WeaponSystem, `features/` contains gameplay modules (player, enemy, items, projectiles, weapons, spawner, camera), `levels/` keeps `world_root.gd` + `main.tscn`, `ui/` stores HUD scenes, and `shared/` holds helper scripts plus placeholder assets (`shared/assets/poc/**` textures + `shared/assets/frames/*.tres`). Config data sits in `game/config/`, while `game/tests/` contains the simulator harness (`tests/sim/`) and `robot/` specs. Raw, non-imported art belongs in `game/assets_raw/` (guarded by `.gdignore`). Repo-level tooling stays in `scripts/` and reusable docs/resources in `docs/`.

## Build, Test, and Development Commands
- `python scripts/devtool.py` – central CLI; option `1` launches the editor, `2` starts the manual sim (after a smoke test), `3` runs the timed sim, `4` kicks off autoplay, `5` executes Robot/unit tests, `6` performs a headless editor smoke run, and option `9` edits `.devenv`.
- `./scripts/run_tests.sh` – direct Robot runner; pass extra args for selective suites.
- `GODOT_BIN=/path/to/godot python scripts/devtool.py` – override the bundled binary under `tools/godot/godot4`.

## Coding Style & Naming Conventions
Stick to GDScript 2.0 with tabs, snake_case files, and PascalCase classes/nodes. Keep assets adjacent to the scenes/scripts that consume them (e.g., `src/features/player/hero.tscn` + `hero_character_body.gd`). When adding shared helpers, place them inside `src/shared/scripts/` and access them through `SingletonUtil`. SpriteFrames resources (like `src/shared/assets/frames/poc_hero_frames.tres`) feed into `AnimationProfile` `.tres` files, which define default animation names + speeds and expose env prefixes for overrides—use those instead of hardcoding timing in scenes. Enemies should inherit from `Monster` so navigation, animation, and health rules stay consistent; override `_on_monster_ready()` / `_on_monster_died()` for bespoke loot or attack logic. Weapons belong to `WeaponDataRework` resources managed by `WeaponSystem`, so avoid ad-hoc timers on the hero—export `initial_weapons`/`weapon_unlock_order` arrays and let the autoload tick them.

## Testing Guidelines
Robot specs live in `game/tests/robot/cases/` and are driven through `./scripts/run_tests.sh`. Each new gameplay system should expose at least one deterministic test scene so Robot can instantiate it without the full world. Keep names descriptive (`*_test.gd`), assert via the supplied helpers, and prefer short runs (<5s) so CI stays fast. Autoplay configs under `game/tests/sim/autoplay/` double as integration smoke tests. Use `projectile_pool_test.gd` as the model for validating singletons that impact performance.

## Simulation & QA CLI
All manual QA flows go through devtool: option `2` runs `res://tests/sim/manual_launcher.gd` with `MANUAL_LAUNCHER_AUTO_EXIT=0`, option `3` prompts for a duration, option `4` feeds an autoplay JSON (default `autoplay_basic.json`). Every sim first triggers the headless editor smoke test, printing logs and saving `smoke.log`. Keep `.devenv` updated (via option `9`) so env-driven tuning (`NF_HERO_MAX_SPEED`, `NF_ENEMY_*`, etc.) matches your experiment.

## Commit & Pull Request Guidelines
Use focused commits following `type(scope): summary` (`refactor(project-structure): move Godot assets under src/`). Each PR should explain the scenario, list verification steps (`devtool → 2`, `run_tests.sh`), and mention any env/config keys you added. Visual changes benefit from GIFs/screenshots. Remove dead files rather than leaving legacy stubs—the repo is intentionally slim for the PC prototype.

## Configuration Notes
`GameConfig` is the source of truth for runtime toggles. Always query `cfg.get_env_value()` (usually via `SingletonUtil`) before relying on exported defaults, and mirror new knobs in `.devenv` or the README’s environment table. Autoload names are stable (`/root/GameConfig`, `/root/EventBus`, `/root/WeaponSystem`, etc.); reuse them instead of introducing new globals. Keep secrets or platform-specific values out of the repo—use env vars or `.devenv`, which is ignored by Git.
