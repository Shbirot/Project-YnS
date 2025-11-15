# Proof-of-Concept Asset Pack

The `game/src/shared/assets/poc/` directory contains quick placeholder art for rapid validation:

```
src/shared/assets/poc/
├── hero/         # Idle + walk spritesheet (4-frame walk cycle)
├── coin/         # Coin SVG
├── stone/        # Rock obstacle
├── tree/         # Tree obstacle
├── projectile/   # Spark projectile texture
└── animal/       # Generic NPC/monster placeholder
```

Hero animations ship with a ready-to-use SpriteFrames resource: `res://src/shared/assets/frames/poc_hero_frames.tres`. Point any `AnimatedSprite2D` at that resource to preview walk cycles.

### Aseprite workflow
1. Save your spritesheets inside `game/src/shared/assets/poc/<category>/`.
2. Keep idle/walk frames in a single PNG (e.g., 4 × 256×256 frames). Update `poc_hero_frames.tres` to reference your sheet.
3. Re-run the game via `python scripts/devtool.py` → manual or autoplay options to verify the new art in context.

Use this folder for quick experiments before committing to production art. Once assets graduate, move them to larger feature-specific directories under `game/src/shared/assets/` (or into `assets_raw/` while iterating outside Godot).

### AnimationProfiles

`res://src/shared/scripts/animation_profile.gd` wraps a SpriteFrames resource with metadata (default animation, per-animation speeds, env prefix). Create a `.tres` beside your feature (e.g., `player/hero_animation_profile.tres`), point it at the SpriteFrames resource you just authored, and list the base speeds you want per animation. At runtime Godot duplicates the frames, applies overrides such as `NF_ANIM_HERO_WALK_SPEED`, and assigns them to the `AnimatedSprite2D`, so you can tune pacing without touching the asset again.
