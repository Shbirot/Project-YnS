# Nightfall Survivor (Android roguelite starter)

Infrastructure scaffolding for a Vampire Survivors–style mobile game built with Godot 4.2. It ships with mocked assets, minimal gameplay (player, enemies, auto-fire projectiles), Android export presets, CI/CD hooks, and helper scripts so you can iterate locally and push to the Play Store when ready.

## Highlights
- **Godot 4 project** ready for desktop + Android builds with per-environment tuning (`dev`, `stage`, `prod`).
- **Mobile-ready controls**: keyboard + virtual drag joystick hybrid for immediate phone testing.
- **Mock gameplay loop**: player, enemy spawner, projectiles, HUD—replace art and extend systems as you design new weapons/upgrades.
- **Automation**: shell scripts for running, editing, exporting; GitHub Actions workflow for reproducible builds.
- **Config-driven balancing**: `GameConfig` autoload toggles spawn rates, analytics flags, and other knobs via environment tags.
- **OOP gameplay stack**: `VisualGameObject → Character → Hero/Monster` hierarchy keeps future entities consistent, while `ConfigManager` + `Logger` give you data-driven tuning and persistent logs out of the box.
- **Low-latency systems**: `MovementSystem`, `CombatSystem`, and `InteractionSystem` centralize hot-path mechanics so the arena can sustain large enemy counts without scattering expensive per-node logic.
- **Persistence-ready**: `PersistenceManager` snapshots hero state (position, coins, health, future progression) every 30s to `user://persistence.json` and restores it on startup—perfect for keeping dev adjustments or future player profiles in sync.
- **Camera-ready**: `CameraController` keeps the hero centered with smooth scrolling and world bounds so the map stays static while the view tracks action.

## Repo layout

```
.
├── game/                # Godot project (scenes, scripts, assets, export presets)
├── scripts/             # Helper scripts (run, edit, Android exports, env setup)
├── docs/                # Architecture, workflow, Android build guides
├── config/              # Environment/keystore placeholders
├── dist/, build/        # Output folders (gitignored)
├── requirements-dev.txt # Python tooling deps (gdtoolkit, invoke, pre-commit)
└── .github/workflows/   # CI pipeline definitions
```

## Quick start

1. **Install dependencies**
   - Godot already bundled under `tools/godot/godot4` (4.2.2). Override with `GODOT_BIN=/path/to/godot` if you have a different build.
   - Android SDK + NDK (run `./scripts/install_android_sdk.sh` on Linux to download cmdline-tools, SDK Platform 34, Build-tools 34.0.0, and NDK 25.2 automatically; requires Java 17+; set `ANDROID_HOME`/`ANDROID_NDK_ROOT` afterward).
   - `python3` + `virtualenv`
2. **Bootstrap tooling**

   ```bash
   cd android_app
   ./scripts/setup_env.sh
   source .venv/bin/activate
   ```

3. **Edit & iterate**

   ```bash
   ./scripts/edit_project.sh                  # Launch the Godot editor (uses bundled binary)
   ./scripts/run_dev.sh desktop               # Boot the dev build (standalone)
   REMOTE_DEBUG=1 ./scripts/run_dev.sh desktop # Same, but auto-connects to the editor debugger
   ```

4. **Android builds**

   ```bash
   ./scripts/run_dev.sh android        # Export + install dev APK and attach debugger
   ./scripts/export_android.sh stage   # Near-prod APK for device QA
   ./scripts/export_android.sh prod    # Release AAB (requires keystore)
   ```

   Stage/prod exports live in `dist/android/<env>/`. Install stage builds with `adb install -r dist/android/stage/nightfall-stage.apk`.

### Remote debugging helper

Set `REMOTE_DEBUG=1` to have `run_dev.sh desktop` pass `--remote-debug tcp://127.0.0.1:6010` so the standalone build connects back to the editor (open the project in the editor beforehand to accept the connection). `run_dev.sh android` always sets up `adb reverse tcp:6010 tcp:6010`; make sure the project’s *Project Settings → Debug → Remote* host/port match (`127.0.0.1:6010`) before attaching from the editor’s Remote tab.

### Configuration & logging

- Tuning knobs live in `game/config/settings/defaults.json` and per-environment overrides in `game/config/settings/{dev,stage,prod}.json`. Query them anywhere with `ConfigManager.get_value("hero.move_speed")`.
- Runtime logs stream to stdout and to `user://logs/nightfall_YYYYMMDD.log` (rotating daily) via the `Logger` autoload.

5. **CI/CD**
   - Pushes to `develop`/`main` trigger `.github/workflows/ci.yml`, running desktop + stage exports inside a containerized Godot build.

## Environment profiles

Environment | Purpose | Differences
---|---|---
`dev` | editor + local desktop/mobile debugging | slower enemy cadence, analytics disabled
`stage` | device QA, release-candidate balancing | faster spawns, analytics still disabled
`prod` | Play Store builds | spawn buffs, analytics enabled, release keystore required

`GameConfig` chooses the profile via (1) `custom_features` inside export presets (`env.dev`, `env.stage`, `env.prod`) or (2) the `NIGHTFALL_ENV` env var for local runs.

## Next steps / customization ideas
1. Flesh out ability/weapon systems under `game/scripts/` and add upgrade data in `config/data/`.
2. Replace placeholder SVG art with production assets (spritesheets, particles, SFX) and expand the asset pipeline via `tools/`.
3. Add save systems, meta-progression, and analytics toggled through `GameConfig` to keep prod-only code paths isolated.
4. Expand CI to sign prod bundles, upload artifacts, or run Firebase Test Lab smoke tests.
