# Testing approach

## Editor-driven tests
- **Manual smoke**: Launch scenes via `F6` (current scene) or `scripts/run_desktop.sh`. Keep quick-to-load test scenes in `game/tests/`.
- **Regression capture**: Record `.tscn` fixtures for future automation (e.g., spawn tables, ability configs) instead of random scripts.

## Automated options
1. **GUT (Godot Unit Test)**: Drop the addon under `game/addons/gut/`, create tests in `game/tests/unit/`, and run through `godot4 --headless --run main.gd -s res://addons/gut/gut_cmdln.gd`.
2. **WAT**: For UI automation/screenshot diffing.
3. **Headless replays**: Add deterministic simulations by scripting `Main` to run for N seconds in headless mode and assert world state.

## Continuous integration
- `.github/workflows/ci.yml` installs Godot (via docker), runs lint (optional) and exports desktop + stage builds so every push stays deployable.
- Add emulator-based instrumentation tests later (Android instrumented or Firebase Test Lab) once input systems solidify.

## Telemetry hooks
- `GameConfig` exposes `analytics_enabled`. Gate analytics / crash reporters behind that flag so automation can assert that stage/dev exports never phone home.
