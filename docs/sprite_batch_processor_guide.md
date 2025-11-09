# Sprite Batch Processor Guide

## Overview

The `process_sprites.sh` script automatically converts JPG images from Leonardo.AI (or any source) into game-ready PNG assets with transparency, glow maps, and portraits.

---

## What It Does

For **each JPG file** in a directory, the script creates **3 PNG files**:

1. **`*_sprite.png`** - Main character sprite (256x256)
2. **`*_glow.png`** - Grayscale glow map for shader effects (256x256)
3. **`*_portrait.png`** - Portrait/icon version (256x256, cropped to upper portion)

---

## Usage

### Basic Usage

```bash
./scripts/process_sprites.sh <directory_path>
```

### Examples

**Process all JPGs in Downloads folder:**
```bash
./scripts/process_sprites.sh ~/Downloads/leonardo_sprites
```

**Process JPGs in project root:**
```bash
./scripts/process_sprites.sh .
```

**Process JPGs in a specific folder:**
```bash
./scripts/process_sprites.sh /media/yves/HDD/app/character_images
```

---

## Workflow

### 1. Generate Images with Leonardo.AI

Create your character sprites using Leonardo.AI with these prompts:

**Example Prompt:**
```
top-down view 2D game character sprite, arcane mage wanderer,
wearing flowing midnight blue robes with glowing cyan runic patterns,
holding ornate magical staff with glowing crystal orb,
dark fantasy nightfall theme, centered, game asset style
```

Download all variations as JPG files to a folder (e.g., `~/Downloads/sprites/`)

---

### 2. Run the Script

```bash
cd /media/yves/HDD/app
./scripts/process_sprites.sh ~/Downloads/sprites/
```

**Output:**
```
========================================
  Sprite Batch Processor
========================================

Input directory: /home/user/Downloads/sprites/

Found 5 JPG file(s) to process

Processing: character_1.jpg
  [1/3] Creating sprite PNG (256x256)... ✓
  [2/3] Creating glow map... ✓
  [3/3] Creating portrait (256x256)... ✓
  ✓ Complete! Generated 3 files:
    • character_1_sprite.png
    • character_1_glow.png
    • character_1_portrait.png

Processing: character_2.jpg
  ...

========================================
  Summary
========================================
Total JPGs found:     5
Successfully processed: 5
Output location:      /home/user/Downloads/sprites/

Done! Generated 15 PNG files total.
```

---

### 3. Move Assets to Game Folders

After processing, move the generated PNGs to your game asset folders:

**For Heroes:**
```bash
cp ~/Downloads/sprites/arcane_wanderer_*.png game/assets/characters/heroes/arcane_wanderer/
```

**For Monsters:**
```bash
cp ~/Downloads/sprites/sand_grunt_*.png game/assets/characters/monsters/sand_grunt/
```

---

## File Naming Convention

Input file: `my_character.jpg`

Output files:
- `my_character_sprite.png` - Main game sprite
- `my_character_glow.png` - Glow map for shaders
- `my_character_portrait.png` - UI icon/portrait

---

## Features

✅ **Batch Processing** - Process hundreds of images at once
✅ **Auto-resize** - All outputs are 256x256 (optimal for 2D games)
✅ **Glow Map Generation** - Automatic grayscale conversion with contrast enhancement
✅ **Portrait Cropping** - Smart cropping to upper portion (face/upper body)
✅ **Skip Existing** - Won't overwrite already processed files
✅ **Progress Display** - Shows real-time progress with color-coded output
✅ **Error Handling** - Continues processing even if one file fails

---

## Requirements

- **ImageMagick** - Install if not present:
  ```bash
  sudo apt-get install imagemagick
  ```

- **Bash** - Already available on Linux/Mac

---

## Advanced Options

### Process Only Specific Files

Use a subdirectory:
```bash
mkdir heroes
cp character_*.jpg heroes/
./scripts/process_sprites.sh heroes/
```

### Re-process After Editing

Delete the old PNGs:
```bash
rm ~/Downloads/sprites/*_sprite.png
rm ~/Downloads/sprites/*_glow.png
rm ~/Downloads/sprites/*_portrait.png
```

Then re-run the script:
```bash
./scripts/process_sprites.sh ~/Downloads/sprites/
```

---

## Troubleshooting

### "No JPG/JPEG files found"
- Check that the directory contains `.jpg` or `.jpeg` files
- File extensions are case-insensitive (`.JPG`, `.Jpg`, `.jpeg` all work)

### "ImageMagick convert command not found"
Install ImageMagick:
```bash
sudo apt-get update
sudo apt-get install imagemagick
```

### Files already processed warning
The script skips files that already have all 3 PNG outputs. Delete the PNGs to force re-processing.

### Portrait looks wrong
The script crops the upper 70% of the sprite. If your character is positioned differently, you can manually adjust using:
```bash
convert character_sprite.png -gravity North -crop 256x200+0+0 +repage -resize 256x256! character_portrait.png
```
(Adjust `256x200` to control crop height)

---

## Integration with Game

After processing sprites, update your catalog:

**1. Add entry to `game/config/data/objects/catalog.json`:**
```json
{
  "hero_new_character": {
    "type": "hero",
    "id": "hero_new_character",
    "name": "New Character",
    "scene": "res://scenes/player.tscn",
    "properties": {
      "sprite_texture": "res://assets/characters/heroes/new_character/new_character_sprite.png"
    },
    "metadata": {
      "icon": "res://assets/characters/heroes/new_character/new_character_portrait.png",
      "portrait": "res://assets/characters/heroes/new_character/new_character_portrait.png",
      "glow_texture": "res://assets/characters/heroes/new_character/new_character_glow.png"
    }
  }
}
```

**2. Open Godot to import assets** (they'll be auto-detected)

**3. Test in-game!**

---

## Tips for Best Results

### Leonardo.AI Settings
- **Dimensions**: 512x512 or 1024x1024
- **Model**: Leonardo Diffusion XL or Anime Pastel Dream
- **Prompt Magic**: ON
- **Number of images**: 4 (pick best)

### Image Quality
- Centered character composition works best
- Front-facing or 3/4 view ideal for top-down games
- Clear contrast between character and background
- Avoid too much empty space around character

### Batch Workflow
1. Generate 10-20 variations in Leonardo.AI
2. Download all to one folder
3. Run script once to process all
4. Review outputs, keep the best
5. Move winners to game asset folders

---

## Example Complete Workflow

```bash
# 1. Download Leonardo.AI images to ~/Downloads/new_heroes/
cd /media/yves/HDD/app

# 2. Process all JPGs
./scripts/process_sprites.sh ~/Downloads/new_heroes/

# 3. Review and select best (manually in file browser)

# 4. Copy to game assets
cp ~/Downloads/new_heroes/fire_mage_sprite.png game/assets/characters/heroes/fire_mage/
cp ~/Downloads/new_heroes/fire_mage_glow.png game/assets/characters/heroes/fire_mage/
cp ~/Downloads/new_heroes/fire_mage_portrait.png game/assets/characters/heroes/fire_mage/

# 5. Update catalog.json (manually edit)

# 6. Test in Godot
./scripts/edit_project.sh
```

---

## Summary

This script saves you **tons of time** by automating the conversion of AI-generated images into game-ready assets.

**Instead of:**
- Manually converting each JPG
- Manually creating glow maps
- Manually cropping portraits
- Manually resizing everything

**You just:**
```bash
./scripts/process_sprites.sh my_images/
```

And get all your sprites ready to use! 🎨✨
