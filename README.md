# Nightfall Survivor (Android roguelite starter)

Infrastructure scaffolding for a Vampire Survivors–style mobile game built with Godot 4.2. It ships with mocked assets, minimal gameplay (player, enemies, auto-fire projectiles), Android export presets, CI/CD hooks, and helper scripts so you can iterate locally and push to the Play Store when ready.

## Highlights
- **Godot 4 project** ready for desktop + Android builds with per-environment tuning (`dev`, `stage`, `prod`).
- **Mobile-ready controls**: keyboard + virtual drag joystick hybrid for immediate phone testing.
- **Mock gameplay loop**: player, enemy spawner, projectiles, HUD—replace art and extend systems as you design new weapons/upgrades.
- **Automation**: shell scripts for running, editing, exporting; GitHub Actions workflow for running tests.
- **Config-driven balancing**: `GameConfig` autoload toggles spawn rates, analytics flags, and other knobs via environment tags.
- **OOP gameplay stack**: `VisualGameObject → Character → Hero/Monster` hierarchy keeps future entities consistent, while `ConfigManager` + `Logger` give you data-driven tuning and persistent logs out of the box.
- **Centralized Utilities**: A suite of `utils` scripts (`SceneTreeUtil`, `TypeUtil`, `NodeUtil`, `TargetFinderUtil`) provide reusable helpers for common operations like accessing singletons, coercing types, and finding nodes.
- **Low-latency systems**: `MovementSystem`, `CombatSystem`, and `InteractionSystem` centralize hot-path mechanics so the arena can sustain large enemy counts without scattering expensive per-node logic.
- **Persistence-ready**: `PersistenceManager` snapshots hero state (position, coins, health, future progression) every 30s to `user://persistence.json` and restores it on startup—perfect for keeping dev adjustments or future player profiles in sync.
- **Camera-ready**: `CameraController` keeps the hero centered with smooth scrolling and world bounds so the map stays static while the view tracks action.
- **Obstacle-friendly**: `ImmovableObject` + debug key `O` let you drop blocking/non-blocking props (stones, trees, bushes) with configurable footprints so encounters feel natural without ad-hoc collision hacks.
- **Boot chain**: `BootLoader` performs startup preflight steps, then hands control to `GameController`, which centralizes core services (logger, config, persistence) and exposes the lightweight TCP API manager for automation-friendly system commands.
- **Weaponized projectiles**: the new `Weapon` + `WeaponAmmunition` layer feeds advanced projectile types (spark shots, line-of-sight tornados, explosive fireballs, dynamite charges, lightning bounces) with configurable on-fire/on-impact/tail effects.
- **Attributes & combat feedback**: `AttributesManager` tracks HP/fire rate/projectile speed/crit stats, the damage system rolls crits, and `DamageNumberManager` splashes colored numbers (physical, elemental, crit variants) at hit positions for instant readability.
- **Data-driven factories**: edit `game/config/data/objects/catalog.json` to describe heroes, monsters, projectiles, and weapons; the `ObjectCatalog` autoload consumes that file directly at runtime so no external tooling is required.
- **Menu-driven launch**: startup and loadout windows pause the simulation until you pick a hero/weapon combo, then resume play with the chosen stats—perfect for testing multiple builds quickly.

## Repo layout

```
.
├── game/                # Godot project (scenes, scripts, assets, export presets)
├── scripts/             # Helper scripts (run, edit, Android exports, env setup)
├── docs/                # Architecture, workflow, and diagram documents
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

5. **Reference diagrams**
   - See `docs/block_diagram.md` for a high-level component diagram.
   - See `docs/diagrams/` for more detailed diagrams of the architecture, including:
     - `inheritance_map.md`: The class inheritance hierarchy.
     - `data_flow.md`: How data flows between core systems.
     - `object_creation.md`: The object creation process from JSON to an in-game node.
   - `docs/object_factory.md` documents the JSON→Godot factory workflow.

6. **Testing**
   - The project uses the Robot Framework to run a suite of GDScript-based logic tests.
   - Run the full test suite with `./run_tests.sh`.
   - Add new tests to the `game/tests/robot/cases/` directory and update `tests/robot/logic_tests.robot` to include them.

7. **Object catalog (optional but recommended)**
   - Author specs in `game/config/data/objects/catalog.json`. Each top-level key (`hero`, `monster`, `projectile`, `weapon`, etc.) maps ids to dictionaries describing their stats, scenes, and metadata.
   - The `/root/ObjectCatalog` autoload loads that JSON directly; call helpers such as `ObjectCatalog.create_hero("hero_arcane")` or `ObjectCatalog.list_entries("weapon")` from anywhere in-game.

8. **In-game controls**
   - Bottom-right HUD buttons pause the game. “Pause” opens the pause menu (resume/restart/exit) while “Attributes” opens the live attribute inspector powered by `AttributesManager`.

9. **CI/CD**
   - Pushes to `dev`, `stage`, `prod`, and `master` branches (and pull requests to `master`) trigger the `.github/workflows/ci.yml` workflow.
   - The CI pipeline runs the full Robot Framework test suite to ensure that no regressions have been introduced.

## Environment profiles

Environment | Purpose | Differences
---|---|---
`dev` | editor + local desktop/mobile debugging | slower enemy cadence, analytics disabled
`stage` | device QA, release-candidate balancing | faster spawns, analytics still disabled
`prod` | Play Store builds | spawn buffs, analytics enabled, release keystore required

`GameConfig` chooses the profile via (1) `custom_features` inside export presets (`env.dev`, `env.stage`, `prod`) or (2) the `NIGHTFALL_ENV` env var for local runs.

## Weapons & Projectiles

- **Weapons** (`scripts/weapons/weapon.gd`) act as non-visual resources that bundle firing rate, ammo configuration, and projectile scenes. The hero now equips `resources/weapons/basic_wand.tres`, which overrides the old fire interval/projectile settings.
- **WeaponAmmunition** (`scripts/weapons/ammunition_base.gd`) lays the groundwork for projectile, melee, and environmental damage types. Projectile ammunition is hooked up today; melee/environmental slots are placeholders for future systems.
- **Projectile families** (all under `game/scenes/projectiles/`):
  - *Magic Spark*: blue sparkles with tail + impact glint (good for wands).
  - *Tornado beam*: line-of-sight shot that pierces multiple enemies.
  - *Fireball*: explodes, spawns a lingering damage field with custom impact effect.
  - *Dynamite*: slow-moving stick with burning tail.
  - *Lightning bolt*: bounces across nearby enemies several times.

## API Manager

- `ApiManager` (`scripts/core/api_manager.gd`) opens a tiny TCP server on port `6969` and accepts commands such as `pause`, `resume`, `reset`, `list_components`, `show_window <name>`, and `hide_window <name>`. It forwards requests to `GameController`, which exposes placeholder handlers. Connect via `nc localhost 6969` during development for quick automation.

## Next steps / customization ideas
1. Flesh out ability/weapon systems under `game/scripts/` and add upgrade data in `config/data/`.
2. Replace placeholder SVG art with production assets (spritesheets, particles, SFX) and expand the asset pipeline via `tools/`.
3. Add save systems, meta-progression, and analytics toggled through `GameConfig` to keep prod-only code paths isolated.
4. Expand CI to sign prod bundles, upload artifacts, or run Firebase Test Lab smoke tests.
