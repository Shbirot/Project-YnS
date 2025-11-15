# Reimplementation Plan

The goal is to reboot the Nightfall Survivor codebase so it reflects modern Godot 4.2 practices outlined in the preceding research notes (`01`–`07`). The plan below sequences the work so that every milestone produces a verifiable deliverable with scripts, scenes, and tooling aligned to the intended Survivors-like experience.

---

## Phase 0 – Foundations & Audits
1. **Repository snapshot**: cut a branch (`rework/core-architecture`) and archive the current `game/` directory so experiments can be reverted quickly.
2. **Tools bootstrap**: ensure `./scripts/edit_project.sh` points to a reproducible Godot binary and that `gdtoolkit` + `pre-commit` run locally (see `05` + `06` notes on profiler usage).
3. **Visual target lock**: choose the hero + enemy visual pillars from `04_pixel_art_and_visual_settings.md` so animation requirements are fixed before coding.

## Phase 1 – Scene Tree & Autoloads
1. **Create a clean `Main.tscn`** with: `WorldRoot (Node2D)`, `CameraRig (Camera2D)`, `Lighting` (if any), `HUD (CanvasLayer)`, and `SpawnerController`.
2. **Autoloads**:
   - `GameConfig` only handles environment flags.
   - `ObjectCatalog` provides packed scene/resource references (structured per `01` + `07`).
   - `Log`, `SingletonUtil`, and `EventBus` (new) so systems communicate via signals instead of direct node lookups.
3. **Testing hook**: embed `tests/robot/cases/scene_boot_test.gd` to assert the tree boots without missing dependencies.

## Phase 2 – Player & Camera
1. **Player scene** (`Hero.tscn`):
   - Node order: `Hero (CharacterBody2D)` → `SpriteFrames` via `AnimatedSprite2D`, `CollisionShape2D`, `WeaponSocket`.
   - Script logic follows `02_player_movement_and_camera.md`: acceleration/drag handled in `_physics_process`, camera target updated through a `CameraTarget` node.
2. **Camera system**:
   - `CameraRig` is a `RemoteTransform2D` or `Camera2D` script that lerps toward `Hero` and clamps to level bounds (`WorldBounds` helper from `05`).
   - Add shake/zoom hooks for hit feedback per research doc `06`.
3. **Animation state machine**:
   - Use `AnimationTree` if directional blends are needed; otherwise, `AnimatedSprite2D` with 8-direction atlas keyed to input vectors (see `03` for frame layout).

## Phase 3 – Enemies, Spawning, and Combat Loop
1. **Enemy base class**:
   - Implement `Monster.gd` (inherits `CharacterBody2D`) with AI ticks pulled from `05_combat_and_interactions.md`.
   - Keep movement targeting the hero using `NavigationServer2D` or steering heuristics described in `06`.
2. **SpawnerController**:
   - Reads wave definitions from `config/data/waves.json`.
   - Emits signals (`enemy_spawned`, `wave_completed`) so HUD/progression listens instead of tight coupling.
3. **Combat systems**:
   - Dedicated `DamageSystem` singleton handles hit registration, knockback, and XP drops.
   - Projectiles use pooled nodes (`ObjectPool` described in `06`) to avoid churn; tie into Robot tests (`tests/robot/cases/projectile_pool_test.gd`).

## Phase 4 – Weapons, Abilities, and Progression
1. **Weapon resources**:
   - Define `WeaponData (Resource)` with fire rate, projectile scene, behavior flags (pierce, boomerang, orbit).
   - Hero holds a list of weapon instances; update `WeaponSystem` autoload to tick them each frame.
2. **Experience & level-up**:
   - Implement a `LevelManager` that listens to `xp_collected`, presents upgrade options (cards) in HUD, and mutates weapon data in-place.
3. **Passive systems**:
   - Movement modifiers, magnet range, and pickup logic as described in `07_survivors_like_guides.md`, all driven by resource configs so tuning stays data-first.

## Phase 5 – Visual Polish & Feedback
1. **Sprite/animation pipeline**:
   - Follow `03_sprites_and_animation_pipeline.md` by exporting from Aseprite → `resources/sprites/<entity>/`.
   - Idle “breathing” loops get their own animation track; wire them to play when velocity < threshold.
2. **Particles & shaders**:
   - Introduce `HitFlashMaterial` and `DissolveShader` referenced in `04`.
   - Add mono-color particles for damage numbers and XP orbs to improve clarity.
3. **UI/UX loop**:
   - Rebuild HUD using `Control` nodes with theme overrides (see `04` for color palette).

## Phase 6 – Performance & QA
1. **Profiling**:
   - Use Godot’s built-in profiler and `--disable-render-loop` headless tests to capture CPU hotspots.
   - Simulate 500+ enemies using stress scenes documented in `06`.
2. **Robot coverage**:
   - Expand suites with cases for movement smoothing, enemy pooling, XP gain, and weapon upgrades.
3. **CI hooks**:
   - Update `.github/workflows/ci.yml` to run `gdformat`, `run_tests.sh`, and export a minimal build for regression validation.

## Phase 7 – Cutover & Documentation
1. **Migration**:
   - Replace old scenes incrementally: hero → enemies → systems. Maintain adapters so save data or configs keep loading.
2. **Docs**:
   - Update `README.md` quick-start steps to match the new pipelines.
   - Produce a “getting started” walkthrough inside `godot_research/README.md` summarizing essential how-tos for future contributors.
3. **Retrofit assets**:
   - Tag any remaining placeholder art for replacement, referencing the mood boards in `04`.

---

Executing the phases sequentially ensures each subsystem is grounded in a clean architecture, and the research insights remain actionable. Treat every phase as a reviewable milestone—merge only after Robot tests pass and the intended deliverable (scene, system, or doc) behaves like the Survivors-style gameplay target. Continue to log findings back into the `godot_research` folder so future iterations can lean on the same shared knowledge base.
