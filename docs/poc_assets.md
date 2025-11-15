# Proof-of-Concept Asset Pack

The `game/assets/POC_0/` directory contains quick placeholder art for rapid validation:

```
POC_0/
├── hero/         # Idle + walk spritesheet (4-frame walk cycle)
├── coin/         # Coin SVG
├── stone/        # Rock obstacle
├── tree/         # Tree obstacle
├── projectile/   # Spark projectile texture
└── animal/       # Generic NPC/monster placeholder
```

Hero animations ship with a ready-to-use SpriteFrames resource: `res://resources/rework/poc_hero_frames.tres`. Point any `AnimatedSprite2D` at that resource to preview walk cycles.

### Aseprite workflow
1. Save your spritesheets inside `game/assets/POC_0/<category>/`.
2. Keep idle/walk frames in a single PNG (e.g., 4 × 256×256 frames). Update `poc_hero_frames.tres` to reference your sheet.
3. Re-run the game via `python scripts/devtool.py` → manual or autoplay options to verify the new art in context.

Use this folder for quick experiments before committing to production art. Once assets graduate, move them to the canonical directories under `game/assets/`.
