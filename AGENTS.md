# Repository Guidelines

## Project Structure & Module Organization
`game/` carries the entire Godot project (rework scenes, scripts, autoloads, resources) and is the source for exports. CLI helpers live in `scripts/`, and reference data (waves, weapons) sits in `game/config/` + `game/resources/`. Proof-of-concept art lives under `game/assets/POC_0/` so you can test spritesheets quickly. Automated specs reside in `game/tests/robot/` with the runnable Godot scenes inside `game/tests/robot/cases/`. Generated binaries under `build/`, `dist/`, and the bundled editor in `tools/godot/` must remain untracked.

## Build, Test, and Development Commands
- `./scripts/edit_project.sh` — launches the pinned Godot 4.2 editor; override via `GODOT_BIN=/path/to/godot`.
- `python scripts/devtool.py` — menu-driven hub for launching the editor, running manual simulations (option 2=manual, option 3=timed auto-exit), autoplay, Robot tests, or executing a headless editor smoke run with live logs.
- `./scripts/run_tests.sh [robot args]` — still available if you need to shell into Robot directly; CI mirrors this command.

## Coding Style & Naming Conventions
Use GDScript 2.0 with tab indentation (see `game/scripts/rework/player/hero_character_body.gd`). Keep files snake_case, declare classes with PascalCase `class_name`, and reserve SCREAMING_SNAKE_CASE for constants. Co-locate art, data, and helper scenes with their consuming script so catalog lookups (e.g., `game/resources/rework/`) stay accurate. Run `gdformat game/**/*.gd` or `pre-commit run --all-files` before opening a PR.

## Testing Guidelines
Each `.robot` suite delegates to deterministic Godot cases under `game/tests/robot/cases/*.gd` (e.g., `world_boot_test.gd`). Cover new systems with success/failure scenes so Robot catches regressions. Run `./scripts/run_tests.sh` before pushing; CI mirrors that command. Headless machines can skip UI stories via `SKIP_UI_TESTS=1` or `--codex`.

## Simulation & Autoplay
Use `python scripts/devtool.py` for repeatable QA loops. Option 2 launches the rework scene interactively via `tests/rework/manual_launcher.gd` and keeps it running until you close the window; option 3 prompts for an auto-exit duration if you want hands-free smoke tests. Option 4 runs the headless autoplay simulator (`tests/rework/autoplay/autoplay_runner.gd`) with `res://tests/rework/autoplay/autoplay_basic.json` driving a 20s roam that randomly hunts enemies. Both flows exercise the same WorldRoot scene graph, so failures surface early before Robot/unit coverage runs.

## Commit & Pull Request Guidelines
Commits follow the conventional `type: summary` style used in history (`feat:`, `refactor:`, `test:`). Keep changes focused and mention the subsystem when helpful (`feat(projectiles): add arc shot`). Pull requests should describe impact, note validation commands (`run_dev.sh desktop`, `run_tests.sh`), and link issues. Visual or UX alterations need screenshots or clips, and every PR must call out environment or config updates reviewers must apply.

## Configuration & Security Tips
`GameConfig` switches behavior via export features (`env.dev`, `env.stage`, `env.prod`) or the `NIGHTFALL_ENV` variable. Use its `get_env_value()` helper to layer environment overrides on top of exported defaults (see README’s environment table). When a system needs shared state, route through `SingletonUtil` and the shared autoloads (`EventBus`, `ReworkCatalog`, `LevelManager`) instead of introducing new globals so sensitive toggles remain centralized.
