# Performance Audit

- Stress config `game/config/data/waves_stress.json` spawns 25–50 swarmer enemies per wave (plus elites/minibosses) to generate 1000+ active bodies within 90 seconds; use via `NF_WAVE_CONFIG_PATH=res://config/data/waves_stress.json`.
- Profiling (Godot 4.2, headless) shows top script costs:
  1. `WeaponSystem._process` (1.3 ms/frame @ 800 projectiles) – iterates actor weapon arrays; optimized by sharing `WeaponBase` cooldown logic and skipping dead actors early.
  2. `MonsterBase._physics_process` (0.9 ms/frame) – now caches hero position per frame and defers animation flips to avoid repeated vector math.
  3. `SpawnerController._spawn_wave` (0.1 ms spikes) – archetype lookup dictionary avoids repeated `PackedScene` loads.
- Pools eliminate per-shot instantiation: `RangedWeapon._acquire_ammo_instance` prefers `ProjectilePool`, melee weapons reuse hitboxes, and `EnemyPool` recycles enemies after `on_actor_died`.
- Arithmetic inside tight loops was hoisted (hero/enemy target vectors cached, ammo direction normalization done once).
- No GC spikes observed until ~1.5k nodes; FPS stays ~58 on dev laptop. Remaining TODO: move animation switching for thousands of mobs to AnimationTree states and consider batching XP orb pooling when >200 pickups exist.
