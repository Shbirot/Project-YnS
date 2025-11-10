# Aseprite Sprite Animation Guide

## Overview

Aseprite is the industry-standard tool for creating pixel art and sprite animations. This guide covers installation (including compiling from source for free) and basic animation workflows.

---

## Installation Options

### Option 1: Purchase ($20 - Easiest)

**Pros**: Instant download, supports development, automatic updates
**Cons**: Costs $20

1. Visit https://www.aseprite.org/
2. Click "Get Aseprite"
3. Purchase and download for your platform
4. Install and run

---

### Option 2: Compile from Source (FREE)

**Pros**: Completely free, same features as paid version
**Cons**: Requires compilation, no automatic updates

#### Prerequisites

Install required dependencies:

```bash
# Ubuntu/Debian
sudo apt-get install -y g++ cmake ninja-build libx11-dev libxcursor-dev libxi-dev libgl1-mesa-dev libfontconfig1-dev

# Fedora/RedHat
sudo dnf install -y gcc-c++ cmake ninja-build libX11-devel libXcursor-devel libXi-devel mesa-libGL-devel fontconfig-devel

# Arch Linux
sudo pacman -S gcc cmake ninja libx11 libxcursor libxi mesa fontconfig
```

#### Compile Aseprite

```bash
# 1. Create build directory
mkdir -p ~/aseprite-build
cd ~/aseprite-build

# 2. Download Skia prebuilt library (required dependency)
# Visit: https://github.com/aseprite/skia/releases
# Download the latest Skia release for Linux (e.g., Skia-Linux-Release-x64-libc++.zip)
wget https://github.com/aseprite/skia/releases/download/m102-861e4743af/Skia-Linux-Release-x64-libc++.zip
unzip Skia-Linux-Release-x64-libc++.zip -d skia

# 3. Clone Aseprite source
git clone --recursive https://github.com/aseprite/aseprite.git
cd aseprite

# 4. Create build directory
mkdir build
cd build

# 5. Configure with CMake
cmake \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_CXX_FLAGS:STRING=-stdlib=libc++ \
  -DCMAKE_EXE_LINKER_FLAGS:STRING=-stdlib=libc++ \
  -DLAF_BACKEND=skia \
  -DSKIA_DIR=$HOME/aseprite-build/skia \
  -DSKIA_LIBRARY_DIR=$HOME/aseprite-build/skia/out/Release-x64 \
  -DSKIA_LIBRARY=$HOME/aseprite-build/skia/out/Release-x64/libskia.a \
  -G Ninja \
  ..

# 6. Compile (takes 5-10 minutes)
ninja aseprite

# 7. Run Aseprite
./bin/aseprite
```

#### Create Desktop Launcher (Optional)

```bash
# Create launcher script
cat > ~/aseprite-build/aseprite/build/run-aseprite.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
./bin/aseprite
EOF

chmod +x ~/aseprite-build/aseprite/build/run-aseprite.sh

# Add to PATH (add to ~/.bashrc for permanent)
echo 'export PATH="$HOME/aseprite-build/aseprite/build/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## Basic Aseprite Workflow

### Interface Overview

- **Canvas**: Center workspace where you draw
- **Timeline**: Bottom panel showing frames and layers
- **Tools**: Left sidebar (pencil, eraser, selection, etc.)
- **Color Palette**: Right sidebar
- **Layers**: Right panel showing layer stack

---

## Creating Walk Animation from Existing Sprite

### Step 1: Import Your Sprite

```
File → Open → Select your sprite PNG (e.g., arcane_wanderer_sprite.png)
```

Your sprite is now loaded as Frame 1.

---

### Step 2: Set Up Animation Frames

1. **Create new frames**:
   - Click the "New Frame" button in Timeline (or press `Alt+N`)
   - Create 4 frames total for one walk cycle

2. **Duplicate frames**:
   - Right-click Frame 1 → Duplicate
   - Repeat until you have 4 frames

---

### Step 3: Enable Onion Skinning

**Onion skinning** lets you see previous/next frames while editing.

```
1. Click the onion skin icon in Timeline (or press F3)
2. Adjust opacity slider to see ghosted previous frames
3. Set to show 1-2 frames before/after current frame
```

---

### Step 4: Separate Body Parts into Layers

This is the KEY to easy animation.

**Method A: Manual Layer Creation**

1. **Create layers**:
   ```
   Layer → New Layer (or Shift+N)
   ```
   Create these layers:
   - `torso` (head, body, robes - mostly static)
   - `left_leg`
   - `right_leg`
   - `effects` (magical aura, glow)

2. **Move parts to layers**:
   - Select Frame 1
   - Use **Rectangular/Polygonal Lasso** tool (M key)
   - Select leg area
   - Cut (Ctrl+X)
   - Switch to `left_leg` layer
   - Paste (Ctrl+V)
   - Repeat for right leg

**Method B: Quick Selection Workflow**

1. Use **Magic Wand** tool (W key) to select leg area
2. **Layer → New → Layer from Selection**
3. Repeat for other body parts

---

### Step 5: Animate the Walk Cycle

Now animate each frame by moving legs:

#### Frame 1: Left Leg Forward

```
1. Select Frame 1 in Timeline
2. Select `left_leg` layer
3. Press Ctrl+T (Transform tool)
4. Move leg forward slightly
5. Rotate leg ~10-15 degrees forward
6. Press Enter to apply
```

#### Frame 2: Neutral Stance

```
1. Select Frame 2
2. Keep legs in center/neutral position (original pose)
```

#### Frame 3: Right Leg Forward

```
1. Select Frame 3
2. Select `right_leg` layer
3. Press Ctrl+T
4. Move leg forward slightly
5. Rotate ~10-15 degrees forward
6. Press Enter
```

#### Frame 4: Neutral Stance (Copy of Frame 2)

```
1. Right-click Frame 2 → Duplicate
2. Drag to Frame 4 position
```

---

### Step 6: Preview Animation

```
1. Press Enter or click Play button in Timeline
2. Adjust frame duration: Right-click frame → Frame Properties → Set to 100-150ms
3. Loop animation to check smoothness
```

---

### Step 7: Create 4 Directions

You now have a walk cycle for one direction. Repeat for 4 directions:

#### DOWN (toward camera) - DONE ABOVE

#### UP (away from camera)

1. Create 4 new frames
2. Flip sprite vertically or adjust view angle
3. Animate legs same way

#### LEFT

1. Create 4 new frames
2. Transform → Flip Horizontal (if needed)
3. Animate side view walk

#### RIGHT

1. Can often mirror the LEFT frames
2. Use Edit → Flip Horizontal on all layers

---

### Step 8: Export as Sprite Sheet

```
File → Export Sprite Sheet

Settings:
- Sheet Type: By Rows
- Columns: 4 (frames per direction)
- Rows: 4 (directions: down, left, right, up)
- Output File: arcane_wanderer_walk_sheet.png
- Options:
  ✓ Trim Sprite
  ✓ Trim Cels (optional)
  - Size: 256x256 per frame
```

Final output: 1024x1024 PNG with 4×4 grid (16 frames)

---

## Useful Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Alt+N` | New Frame |
| `F3` | Toggle Onion Skin |
| `Ctrl+T` | Transform Tool |
| `M` | Rectangular Marquee (selection) |
| `W` | Magic Wand |
| `V` | Move Tool |
| `B` | Pencil Tool |
| `Enter` | Play/Pause Animation |
| `Shift+N` | New Layer |
| `Ctrl+Z` | Undo |
| `Ctrl+Shift+Z` | Redo |
| `Tab` | Hide/Show UI panels |

---

## Tips for Better Walk Animations

### 1. **Keep Torso Mostly Still**
Only legs should move significantly. Head/body can bob slightly (1-2 pixels up/down).

### 2. **Small Movements Go a Long Way**
Don't over-animate. Subtle shifts (5-10 pixels) work best for top-down sprites.

### 3. **Add Secondary Motion**
- Robes: Offset slightly each frame for cloth flow
- Arms: Small swing opposite to legs
- Magical aura: Pulse or flicker effect

### 4. **Frame Timing**
- Fast walk: 80-100ms per frame
- Normal walk: 120-150ms per frame
- Slow walk: 180-200ms per frame

### 5. **Use Reference**
Watch real walk cycles or other pixel art games. Study how legs move.

### 6. **Test in Godot Early**
Export your sprite sheet and test in Godot frequently to see how it looks in-game.

---

## Troubleshooting

### "Legs look disconnected from body"

- Make sure leg layers are positioned correctly under torso
- Check layer order: `effects` → `torso` → `left_leg` → `right_leg`
- Adjust leg anchor point (hip joint)

### "Animation is too choppy"

- Add more frames (6-8 instead of 4)
- Use smoother transform transitions
- Enable "Ease in/out" if using tweening

### "Sprite looks different in each frame"

- Use guidelines (View → Grid → Show Grid)
- Lock `torso` layer to keep it static
- Use onion skinning to maintain consistency

### "Exported sprite sheet is wrong size"

- Check frame size in Export dialog
- Verify columns/rows match your layout
- Use "Trim Sprite" to remove extra space

---

## Advanced: Auto-Animation with Cel Links

For repeated elements (like neutral stance):

```
1. Right-click Frame 2 (neutral)
2. Select "Link Cels"
3. Any edit to Frame 2 updates Frame 4 automatically
```

---

## Integration with Godot

After exporting your sprite sheet:

### 1. Import to Godot

```bash
cp ~/aseprite-build/output/arcane_wanderer_walk_sheet.png \
   game/assets/characters/heroes/arcane_wanderer/
```

### 2. Create Animation in Godot

```
1. Select sprite node in scene
2. Animation panel → New Animation
3. Add frames from sprite sheet
4. Set frame duration
5. Test in game!
```

See `docs/asset_import_guide.md` for more details.

---

## Resources

- **Official Docs**: https://www.aseprite.org/docs/
- **Tutorial Videos**: https://www.youtube.com/c/MortMort (excellent pixel art tutorials)
- **Pixel Art Community**: https://lospec.com/
- **Walk Cycle Reference**: https://blog.studiominiboss.com/pixelart

---

## Summary

**Quick Workflow Recap:**

1. Install Aseprite (buy or compile)
2. Import sprite
3. Create 4 frames
4. Separate body parts into layers
5. Animate legs using Transform tool
6. Preview with onion skinning
7. Export as sprite sheet
8. Import to Godot

**Time estimate**: 30-60 minutes for first walk cycle, 10-15 minutes once practiced.

Happy animating!
