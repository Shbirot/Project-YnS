# Project Structure

This repo follows a feature-first layout so each gameplay system owns its scenes, scripts, and supporting assets. The Godot project lives under `game/`, while auxiliary tooling/documentation stays at the repo root.

```
/ (repo root)
├── game/
│   ├── project.godot
│   ├── src/
│   │   ├── autoload/          # GameConfig, EventBus, LevelManager, DamageSystem, ProjectilePool, WeaponSystem…
│   │   ├── features/          # player/, enemy/, items/, projectiles/, weapons/, spawner/, camera/
│   │   ├── levels/            # world_root.gd + main.tscn (future levels live here too)
│   │   ├── shared/
│   │   │   ├── scripts/       # SingletonUtil, future helpers
│   │   │   └── assets/        # poc/ textures + SpriteFrames, shaders, fonts, audio
│   │   └── ui/                # HUD scenes/components
│   ├── tests/
│   │   ├── sim/               # manual launcher + autoplay runner/configs
│   │   └── robot/             # deterministic Robot Framework cases
│   ├── config/                # Wave JSON and other tuneable data blobs
│   └── assets_raw/            # Non-imported source art (guarded by .gdignore)
├── scripts/                   # devtool.py, run_tests.sh, setup helpers
├── docs/                      # Contributor-facing references (poc_assets, design notes, etc.)
└── tools/                     # Bundled Godot binary or future SDKs
```

## Conventions
- **Scenes + scripts live together** under `src/features/<name>/`. Keep supporting `.tres`/`.tscn` files beside those scripts unless they are shared (in which case move them under `src/shared/`).
- **Autoloads** always reside in `src/autoload/` and are registered via `project.godot`. Access them through `SingletonUtil` so both game code and automation flows stay in sync.
- **Assets** that must be imported by Godot live under `src/shared/assets/`. Use `src/shared/assets/poc/` for placeholder textures and drop raw source files into `assets_raw/` to keep them out of Godot’s importer until they are ready.
- **Levels** live in `src/levels/`; add new scenes there and point `project.godot`’s `run/main_scene` at the level you want to boot.
- **UI** components stay under `src/ui/` and should favor reusable sub-scenes under `ui/components/` when you add them.

## Adding New Features
1. Create a subfolder under `game/src/features/` (e.g., `abilities/`) with the scene (`ability.tscn`), script (`ability.gd`), and local assets.
2. If the feature needs global access, expose it through an autoloaded singleton or register the scene path via `GameCatalog`.
3. Store shared assets in `src/shared/assets/` and update any SpriteFrames or shader resources to point at the new textures.
4. Wire the feature into a level scene inside `src/levels/` and extend the Robot/autoplay tests so the automation flow exercises it.
5. Document any new env variables or config files in the README/AGENTS to keep the contributor workflow consistent.
