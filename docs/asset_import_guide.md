# Asset Import Guide

This guide explains how to configure import settings for different asset types in Godot for optimal quality and performance.

## Import Settings Overview

Godot allows you to customize how assets are imported. You can set these either:
1. **In the Godot Editor**: Select the asset in FileSystem, go to Import tab
2. **Via .import files**: Manually edit the `.import` file next to each asset

---

## Character Sprites (Heroes, Monsters)

**Recommended for**: Static character sprites, portraits

### Settings:
```
Importer: texture
Type: CompressedTexture2D

Compress:
  Mode: Lossless (0)
  High Quality: true
  Lossy Quality: 0.7 (if using lossy)
  HDR Compression: 1

Detect 3D: Off
Flags:
  Filter: false (for pixel art style)
  Filter: true (for smooth/painted art)
  Mipmaps: false
  Repeat: disabled (0)
```

### Why these settings?
- **Lossless compression**: Preserves all detail for important character visuals
- **Filter off**: Keeps pixel art crisp (enable for smooth painted art)
- **No mipmaps**: 2D sprites don't need mipmaps (used for 3D)

### File Requirements:
- Format: PNG with transparency
- Recommended sizes:
  - Heroes: 256x256 or 512x512
  - Monsters: 128x128 or 256x256
  - Portraits: 256x256

---

## Sprite Sheets / Animations

**Recommended for**: Character animation frames, sprite atlases

### Settings:
```
Importer: texture
Type: CompressedTexture2D

Compress:
  Mode: Lossless (0)
  High Quality: true

Detect 3D: Off
Flags:
  Filter: false (for pixel art)
  Mipmaps: false
  Repeat: disabled
```

### Sprite Sheet Layout:
- Horizontal strip: Frames in a single row (e.g., 8 frames = 512x64 for 64x64 frames)
- Grid: Multiple rows and columns (e.g., 4x4 grid = 256x256 for 64x64 frames)
- Use Godot's AnimatedSprite2D > Add Frames from Sprite Sheet to slice

### File Requirements:
- Format: PNG with transparency
- Frame size: Consistent (all frames same dimensions)
- Spacing: Usually 0px between frames (or specify in Godot)

---

## Projectile Sprites

**Recommended for**: Projectile base sprites, effect sprites

### Settings:
```
Importer: texture
Type: CompressedTexture2D

Compress:
  Mode: VRAM Compressed (2) [for many projectiles]
  Mode: Lossless (0) [for few, important projectiles]

Detect 3D: Off
Flags:
  Filter: true (smooth edges for magical effects)
  Mipmaps: false
  Repeat: disabled
```

### Why VRAM compressed?
- Projectiles spawn frequently (dozens on screen)
- VRAM compression reduces memory usage
- Slight quality loss acceptable for fast-moving objects

### File Requirements:
- Format: PNG with transparency
- Sizes: 64x64 or 128x128 (small, efficient)
- Center origin: Design with center as origin point

---

## Particle Textures

**Recommended for**: Trail particles, impact effects, environmental particles

### Settings:
```
Importer: texture
Type: CompressedTexture2D

Compress:
  Mode: VRAM Compressed (2)
  High Quality: false

Detect 3D: Off
Flags:
  Filter: true (always enable for particles!)
  Mipmaps: false
  Repeat: disabled
```

### Why these settings?
- **VRAM compressed**: Particles spawn in large quantities
- **Filter enabled**: Smooth blending is essential for particle effects
- **High quality off**: Performance matters more than quality for particles

### File Requirements:
- Format: PNG with transparency and gradient alpha
- Sizes: 32x32 or 64x64 (very small)
- Soft edges: Use Gaussian blur for smooth fade

---

## UI Icons (Weapons, Items)

**Recommended for**: HUD icons, weapon selection, inventory

### Settings:
```
Importer: texture
Type: CompressedTexture2D

Compress:
  Mode: Lossless (0)
  High Quality: true

Detect 3D: Off
Flags:
  Filter: true (smooth icons)
  Mipmaps: false
  Repeat: disabled
```

### File Requirements:
- Format: PNG with transparency
- Sizes: 128x128 or 256x256 (depends on UI scale)
- Square aspect ratio: Easier to scale in UI

---

## Background Images

**Recommended for**: Arena backgrounds, environment layers

### Settings:
```
Importer: texture
Type: CompressedTexture2D

Compress:
  Mode: VRAM Compressed (2) [for large backgrounds]
  High Quality: true

Detect 3D: Off
Flags:
  Filter: true
  Mipmaps: false
  Repeat: enabled [if tileable]
```

### File Requirements:
- Format: PNG or JPG (can use JPG if no transparency)
- Sizes: Full screen (1920x1080) or tileable (512x512)
- If tileable: Ensure seamless edges

---

## Glow Maps / Normal Maps

**Recommended for**: Shader inputs (emission maps, lighting)

### Settings:
```
Importer: texture
Type: CompressedTexture2D

Compress:
  Mode: VRAM Compressed (2)
  Normal Map: true [for normal maps only]

Detect 3D: Off
Flags:
  Filter: true
  Mipmaps: false
  Repeat: disabled
```

### File Requirements:
- Glow maps: Grayscale PNG (white = bright, black = no glow)
- Normal maps: RGB PNG (not needed for 2D, but if using)
- Same size as base texture

---

## Quick Reference Table

| Asset Type | Compression | Filter | Size | Format |
|------------|-------------|--------|------|--------|
| Hero Sprite | Lossless | Off/On | 256-512 | PNG |
| Monster Sprite | Lossless | Off/On | 128-256 | PNG |
| Sprite Sheet | Lossless | Off | Varies | PNG |
| Projectile | VRAM/Lossless | On | 64-128 | PNG |
| Particle | VRAM | On | 32-64 | PNG |
| UI Icon | Lossless | On | 128-256 | PNG |
| Background | VRAM | On | 512-1920 | PNG/JPG |
| Glow Map | VRAM | On | Match base | PNG |

---

## Batch Import Settings (Advanced)

If you have many assets, create import presets:

1. **In Godot Editor**: Import one asset with correct settings
2. **Copy .import file**: Copy the `.import` file as a template
3. **Apply to others**: Paste and rename for similar assets

Or use Godot's import preset system (Godot 4.x feature).

---

## Performance Tips

1. **Use texture atlases** for characters with many animations
   - Combines multiple sprites into one texture
   - Reduces draw calls
   - Better GPU batching

2. **VRAM compression** for anything spawned frequently
   - Projectiles, particles, enemies (if many)
   - Saves memory at slight quality cost

3. **Lossless for key visuals**
   - Hero character, important bosses
   - UI elements that are always visible
   - Anything zoomed in or static on screen

4. **Filter on/off**
   - Pixel art: Filter OFF (crisp pixels)
   - Painted/smooth art: Filter ON (smooth scaling)
   - Particles: ALWAYS ON (smooth blending)

---

## Troubleshooting

### Sprites look blurry
- **Cause**: Filter is enabled on pixel art
- **Fix**: Set Filter to `false` in import settings

### Sprites have jagged edges
- **Cause**: Filter is disabled on smooth art
- **Fix**: Set Filter to `true` in import settings

### Particles look pixelated
- **Cause**: Filter is disabled
- **Fix**: Always enable Filter for particles

### Game uses too much memory
- **Cause**: Too many lossless/high-res textures
- **Fix**: Use VRAM compression for frequent sprites

### Colors look washed out
- **Cause**: sRGB color space mismatch
- **Fix**: Check "sRGB" flag in import (usually auto-detected)

---

## Example .import File

Here's a sample `.import` file for a hero sprite:

```ini
[remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://unique_id_here"
path="res://.godot/imported/hero_arcane.png-hash.ctex"

[deps]

source_file="res://assets/characters/heroes/arcane_wanderer/hero_arcane.png"
dest_files=["res://.godot/imported/hero_arcane.png-hash.ctex"]

[params]

compress/mode=0
compress/high_quality=true
compress/lossy_quality=0.7
compress/hdr_compression=1
compress/normal_map=0
compress/channel_pack=0
mipmaps/generate=false
mipmaps/limit=-1
roughness/mode=0
roughness/src_normal=""
process/fix_alpha_border=true
process/premult_alpha=false
process/normal_map_invert_y=false
process/hdr_as_srgb=false
process/hdr_clamp_exposure=false
process/size_limit=0
detect_3d/compress_to=0
```

---

## Summary

- **Lossless** for heroes, important visuals
- **VRAM** for projectiles, particles, backgrounds
- **Filter ON** for smooth art and particles
- **Filter OFF** for pixel art
- **Keep sizes reasonable**: 64-512px for sprites

Follow these guidelines for optimal visual quality and performance in your game!
