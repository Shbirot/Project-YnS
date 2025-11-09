# Visual Upgrade Plan - From SVG to Production Assets

This document outlines the complete transition from simple SVG placeholders to production-quality game graphics for Nightfall Survivor.

---

## Table of Contents
1. [Current State Analysis](#current-state-analysis)
2. [Code Infrastructure Changes](#code-infrastructure-changes)
3. [POC Asset Design Workflow](#poc-asset-design-workflow)
4. [Detailed Task List](#detailed-task-list)
5. [AI Tools Recommendations](#ai-tools-recommendations)

---

## Current State Analysis

### What You Have Now
- **Format**: SVG vector files (simple shapes)
- **Coloring**: Uses Godot's `modulate` property for color variants
- **Loading**: Static Texture2D resources in `.tscn` scene files
- **Effects**: No custom shaders, particles limited to basic sprites
- **Asset Structure**: Reusing same SVG (`projectile.svg`) with different colors

### Current Assets
- `hero_pika.svg` - Hero sprite
- `enemy.svg` - Enemy sprite
- `projectile.svg` - Base projectile (recolored for variants)
- `coin.svg` - Collectible
- `weapon_*.svg` - UI weapon icons
- Some PNG obstacles: tree, rock, bush, stone

### What You Need
Production-quality sprites with:
- Detailed textures and visual depth
- Consistent art style (fantasy/dark theme matching "Nightfall Survivor")
- Animated sprite sheets for characters
- Particle effects for magic/combat
- Professional-looking UI elements
- Shader effects for visual polish

---

## Code Infrastructure Changes

### 1. Asset Format Migration Strategy

#### Recommended Format Hierarchy
```
For Characters (Heroes/Monsters):
├── Static Sprites: PNG (256x256 to 512x512)
├── Animated Sprites: Sprite Sheets (PNG)
│   ├── Idle animation (4-6 frames)
│   ├── Walk animation (6-8 frames)
│   ├── Attack animation (4-6 frames)
│   └── Death animation (6-8 frames)
└── Normal Maps: PNG (for depth with shaders)

For Projectiles:
├── Base Sprite: PNG (64x64 to 128x128)
├── Trail Effect: Particle texture (32x32 PNG)
├── Impact Effect: Sprite sheet (4-6 frames, 128x128)
└── Glow Map: PNG (for shader emission)

For Weapons (Icons):
├── UI Icon: PNG (128x128 or 256x256)
└── World Sprite: PNG (64x64) [if weapons are visible]

For Environmental Objects:
├── Props: PNG (128x128 to 512x512)
├── Background: PNG (tiled or full screen)
└── Normal Maps: PNG (optional, for lighting depth)

Texture Atlases (Performance Optimization):
└── Combine multiple sprites into single atlas
    - Character atlas (all hero animations)
    - Projectile atlas (all projectile variants)
    - UI atlas (all icons and HUD elements)
```

#### Why Move from SVG?
1. **Performance**: Rasterized PNGs are faster to render in games
2. **Art Detail**: Can't achieve complex textures/shading with simple SVGs
3. **Effects**: Particle systems, shaders, and normal maps require raster formats
4. **Animation**: Sprite sheets are the standard for 2D game animation
5. **Consistency**: Professional game assets use PNG/texture atlases

---

### 2. New Asset Directory Structure

**Proposed reorganization:**
```
game/assets/
├── characters/
│   ├── heroes/
│   │   ├── arcane_wanderer/
│   │   │   ├── idle.png           # Sprite sheet (4 frames)
│   │   │   ├── walk.png           # Sprite sheet (8 frames)
│   │   │   ├── attack.png         # Sprite sheet (6 frames)
│   │   │   ├── portrait.png       # Static icon (256x256)
│   │   │   └── animations.tres    # AnimationPlayer resource
│   │   └── shadow_knight/         # Second hero
│   │       └── [same structure]
│   └── monsters/
│       ├── sand_grunt/
│       │   ├── idle.png
│       │   ├── walk.png
│       │   ├── attack.png
│       │   └── death.png
│       └── night_wraith/           # Second monster
│           └── [same structure]
│
├── projectiles/
│   ├── magic/
│   │   ├── arcane_spark_base.png       # Main projectile sprite
│   │   ├── arcane_spark_trail.png      # Particle texture
│   │   ├── arcane_spark_impact.png     # Impact sprite sheet
│   │   └── arcane_spark_glow.png       # Emission map for shader
│   └── fire/
│       ├── fireball_base.png
│       ├── fireball_trail.png
│       ├── fireball_impact.png
│       └── fireball_glow.png
│
├── weapons/
│   └── icons/
│       ├── arcane_wand.png         # 256x256 icon
│       ├── fire_staff.png
│       ├── lightning_rod.png
│       └── [other weapons]
│
├── environment/
│   ├── props/
│   │   ├── tree_dark.png
│   │   ├── rock_mossy.png
│   │   ├── crystal_blue.png
│   │   ├── tombstone.png
│   │   └── [other props]
│   ├── backgrounds/
│   │   ├── nightfall_arena.png     # Main background
│   │   └── tile_ground.png         # Tileable ground texture
│   └── particles/
│       ├── dust_particle.png
│       ├── sparkle.png
│       ├── smoke.png
│       └── energy_wisp.png
│
└── ui/
    ├── hud/
    │   ├── health_bar_fill.png
    │   ├── health_bar_bg.png
    │   ├── xp_bar_fill.png
    │   └── button_atlas.png
    └── icons/
        └── app_icon.png
```

---

### 3. AnimatedSprite2D Integration

**Current**: Using static `Sprite2D` nodes
**Upgrade**: Add `AnimatedSprite2D` for character animations

#### Changes Required

**File**: `game/scripts/core/visual_game_object.gd`

**Current implementation:**
```gdscript
@onready var sprite : Sprite2D = _find_or_create_sprite()

func _find_or_create_sprite() -> Sprite2D:
    # ... returns Sprite2D
```

**New implementation (backward compatible):**
```gdscript
# Add exports to choose sprite type
@export var use_animated_sprite := false
@export var sprite_frames : SpriteFrames  # For AnimatedSprite2D

@onready var sprite : Node2D = _find_or_create_sprite()  # Can be Sprite2D or AnimatedSprite2D
@onready var static_sprite : Sprite2D
@onready var animated_sprite : AnimatedSprite2D

func _find_or_create_sprite() -> Node2D:
    # Check for existing AnimatedSprite2D first
    var anim_sprite := get_node_or_null("AnimatedSprite2D")
    if anim_sprite:
        use_animated_sprite = true
        animated_sprite = anim_sprite
        return anim_sprite

    # Fall back to Sprite2D
    var static := get_node_or_null("Sprite2D")
    if static:
        static_sprite = static
        return static

    # Create based on export setting
    if use_animated_sprite:
        animated_sprite = AnimatedSprite2D.new()
        animated_sprite.name = "AnimatedSprite2D"
        if sprite_frames:
            animated_sprite.sprite_frames = sprite_frames
        add_child(animated_sprite)
        return animated_sprite
    else:
        static_sprite = Sprite2D.new()
        static_sprite.name = "Sprite2D"
        add_child(static_sprite)
        return static_sprite

# Animation control methods
func play_animation(anim_name: String, force_restart := false) -> void:
    if animated_sprite:
        if force_restart or animated_sprite.animation != anim_name:
            animated_sprite.play(anim_name)

func stop_animation() -> void:
    if animated_sprite:
        animated_sprite.stop()
```

**File**: `game/scripts/characters/character.gd`

Add state-based animation triggering:
```gdscript
enum AnimState { IDLE, WALK, ATTACK, HURT, DEATH }
var current_anim_state := AnimState.IDLE

func _physics_process(delta: float) -> void:
    _update_animation_state()
    # ... existing logic

func _update_animation_state() -> void:
    if not use_animated_sprite:
        return

    var new_state := AnimState.IDLE

    if velocity.length() > 10.0:
        new_state = AnimState.WALK

    if new_state != current_anim_state:
        current_anim_state = new_state
        match new_state:
            AnimState.IDLE:
                play_animation("idle")
            AnimState.WALK:
                play_animation("walk")
            AnimState.ATTACK:
                play_animation("attack", true)
            # ... other states
```

---

### 4. Particle System Setup

**Current**: Using simple sprites for effects (tail, impact)
**Upgrade**: Godot `GPUParticles2D` for professional effects

#### Particle Emitter Template

Create: `game/scenes/effects/particle_templates/magic_trail.tscn`

```
GPUParticles2D (Magic Trail Template)
├── amount: 32
├── lifetime: 0.5
├── explosiveness: 0.1
├── process_material: ParticleProcessMaterial
│   ├── emission_shape: Point
│   ├── direction: Vector3(0, 0, 0)
│   ├── spread: 45.0
│   ├── initial_velocity_min: 20.0
│   ├── initial_velocity_max: 50.0
│   ├── gravity: Vector3(0, 0, 0)
│   ├── scale_min: 0.3
│   ├── scale_max: 0.8
│   ├── color: Color(0.5, 0.8, 1.0, 1.0)  # Blue magic
│   ├── color_ramp: Gradient (fade to transparent)
│   └── hue_variation: 0.1
└── texture: res://assets/projectiles/magic/arcane_spark_trail.png
```

#### Integration into Projectiles

**File**: `game/scripts/projectiles/projectile_base.gd`

```gdscript
@export var trail_particles : PackedScene  # Assign particle scene
var _active_trail : GPUParticles2D

func _ready() -> void:
    super._ready()
    if trail_particles:
        _active_trail = trail_particles.instantiate()
        add_child(_active_trail)
        _active_trail.emitting = true

func _on_impact() -> void:
    if _active_trail:
        _active_trail.emitting = false
        # Let particles finish before cleanup
        await get_tree().create_timer(_active_trail.lifetime).timeout
```

---

### 5. Shader Implementation

Add visual effects using custom shaders.

#### Shader 1: Glow/Emission for Projectiles

Create: `game/shaders/projectile_glow.gdshader`

```glsl
shader_type canvas_item;

uniform sampler2D glow_map : hint_default_white;
uniform vec4 glow_color : source_color = vec4(0.5, 0.8, 1.0, 1.0);
uniform float glow_intensity : hint_range(0.0, 3.0) = 1.5;
uniform float pulse_speed : hint_range(0.0, 10.0) = 2.0;

void fragment() {
    vec4 base = texture(TEXTURE, UV);
    vec4 glow = texture(glow_map, UV);

    // Pulsing effect
    float pulse = sin(TIME * pulse_speed) * 0.3 + 0.7;

    // Add glow
    vec3 emission = glow.rgb * glow_color.rgb * glow_intensity * pulse;
    COLOR.rgb = base.rgb + emission;
    COLOR.a = base.a;
}
```

**Usage in projectile scene:**
```gdscript
# In magic_spark_projectile.tscn
[node name="Sprite2D" type="Sprite2D" parent="."]
texture = ExtResource("arcane_spark_base.png")
material = ShaderMaterial
    shader = ExtResource("projectile_glow.gdshader")
    shader_parameters:
        glow_map = ExtResource("arcane_spark_glow.png")
        glow_color = Color(0.5, 0.8, 1.0, 1.0)
        glow_intensity = 2.0
        pulse_speed = 3.0
```

#### Shader 2: Hit Flash for Characters

Create: `game/shaders/hit_flash.gdshader`

```glsl
shader_type canvas_item;

uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 base = texture(TEXTURE, UV);
    COLOR.rgb = mix(base.rgb, flash_color.rgb, flash_amount);
    COLOR.a = base.a;
}
```

**Character damage flash:**
```gdscript
# In character.gd
func take_damage(amount: float) -> void:
    # ... existing damage logic
    _flash_white()

func _flash_white() -> void:
    if not sprite or not sprite.material:
        return

    # Assumes shader material with flash_amount parameter
    var mat := sprite.material as ShaderMaterial
    var tween := create_tween()
    tween.tween_property(mat, "shader_parameter/flash_amount", 1.0, 0.1)
    tween.tween_property(mat, "shader_parameter/flash_amount", 0.0, 0.1)
```

#### Shader 3: Outline for Selection/Targeting

Create: `game/shaders/outline.gdshader`

```glsl
shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform float outline_width : hint_range(0.0, 5.0) = 1.0;

void fragment() {
    vec4 base = texture(TEXTURE, UV);

    if (base.a > 0.1) {
        COLOR = base;
    } else {
        // Sample neighboring pixels
        float outline = 0.0;
        vec2 pixel_size = TEXTURE_PIXEL_SIZE * outline_width;

        outline += texture(TEXTURE, UV + vec2(pixel_size.x, 0.0)).a;
        outline += texture(TEXTURE, UV + vec2(-pixel_size.x, 0.0)).a;
        outline += texture(TEXTURE, UV + vec2(0.0, pixel_size.y)).a;
        outline += texture(TEXTURE, UV + vec2(0.0, -pixel_size.y)).a;

        if (outline > 0.0) {
            COLOR = outline_color;
        }
    }
}
```

---

### 6. Performance Optimization: Texture Atlases

For better draw call batching, combine multiple sprites into texture atlases.

#### Using Godot's Built-in Atlas System

**Step 1**: Create atlas resource

File: `game/assets/characters/heroes/hero_atlas.png`
- Single image containing all hero sprite frames in a grid
- E.g., 8 columns x 4 rows = 32 frames (multiple animations)

**Step 2**: Configure in SpriteFrames

```gdscript
# In hero_arcane.tres (SpriteFrames resource)
[resource]
animations = [
    {
        "name": "idle",
        "speed": 8.0,
        "loop": true,
        "frames": [
            # Each frame references region of atlas
            AtlasTexture(atlas: hero_atlas.png, region: Rect2(0, 0, 64, 64)),
            AtlasTexture(atlas: hero_atlas.png, region: Rect2(64, 0, 64, 64)),
            # ... more frames
        ]
    },
    # ... more animations
]
```

**Step 3**: Use in catalog

```json
{
  "hero": {
    "hero_arcane": {
      "properties": {
        "sprite_frames": "res://assets/characters/heroes/hero_arcane_frames.tres"
      }
    }
  }
}
```

---

### 7. Catalog Updates

Update `game/config/data/objects/catalog.json` to reference new assets:

```json
{
  "hero": {
    "hero_arcane": {
      "type": "hero",
      "id": "hero_arcane",
      "name": "Arcane Wanderer",
      "scene": "res://scenes/player.tscn",
      "properties": {
        "max_health": 140,
        "move_speed": 320,
        "base_damage": 12,
        "equipped_weapon": "res://resources/weapons/arcane_wand.tres",
        "use_animated_sprite": true,
        "sprite_frames": "res://assets/characters/heroes/arcane_wanderer/animations.tres"
      },
      "metadata": {
        "icon": "res://assets/characters/heroes/arcane_wanderer/portrait.png",
        "description": "Master of mystical energies, strikes from afar with arcane bolts."
      }
    }
  },
  "projectile": {
    "projectile_arcane_spark": {
      "type": "projectile",
      "id": "projectile_arcane_spark",
      "name": "Arcane Spark",
      "scene": "res://scenes/projectiles/magic_spark_projectile.tscn",
      "properties": {
        "damage": 18,
        "speed": 520,
        "lifetime": 2.4,
        "sprite_texture": "res://assets/projectiles/magic/arcane_spark_base.png",
        "trail_particles": "res://scenes/effects/particles/arcane_trail.tscn",
        "impact_effect": "res://scenes/effects/arcane_impact.tscn"
      }
    }
  }
}
```

---

### 8. Import Settings for Assets

**Godot Import Presets** (create `.import` files or set in editor):

For Character Sprites:
```
[remap]
importer="texture"
type="CompressedTexture2D"

[params]
compress/mode=0           # Lossless for pixel art
compress/high_quality=true
compress/lossy_quality=0.7
compress/hdr_compression=1
detect_3d/compress_to=0
flags/filter=false        # Disable filter for pixel art (keep crisp)
flags/mipmaps=false
flags/repeat=0
```

For Particle Textures:
```
[params]
compress/mode=2           # VRAM compressed for particles
flags/filter=true         # Enable filtering for smooth particles
```

---

## POC Asset Design Workflow

This section covers creating actual game art assets using AI tools.

### Art Style Direction for "Nightfall Survivor"

**Theme**: Dark fantasy, night-time setting, magical combat
**Color Palette**:
- Primary: Deep purples, dark blues, midnight blacks
- Accents: Glowing cyan/arcane blue, mystical gold, blood red
- Environment: Mossy greens, weathered stone grays, dark browns

**Style Reference**:
- 2D top-down perspective (like Vampire Survivors)
- Semi-realistic fantasy art
- High contrast for visibility
- Glowing effects for magic/abilities
- Dark atmospheric backgrounds

---

### AI Tools Recommendations

1. **DALL-E 3** (via ChatGPT Plus)
   - Best for: Concept art, hero portraits, detailed sprites
   - Pros: High quality, consistent style with prompts
   - Cons: $20/month, daily limits

2. **Midjourney**
   - Best for: Character concepts, atmospheric backgrounds
   - Pros: Exceptional quality, style consistency
   - Cons: Subscription required, Discord-based

3. **Leonardo.AI** (RECOMMENDED for game assets)
   - Best for: Sprite generation, texture creation, variations
   - Pros: Free tier available, game-focused models, consistent output
   - Cons: Learning curve for optimal results
   - URL: leonardo.ai

4. **Stable Diffusion (via DreamStudio or local)**
   - Best for: Unlimited generation, customization
   - Pros: Full control, no limits, model fine-tuning
   - Cons: Requires setup, lower quality without tweaking

5. **Photopea** (Free Photoshop alternative)
   - Best for: Editing AI outputs, creating sprite sheets, transparency
   - Pros: Free, browser-based, supports PSD/PNG
   - URL: photopea.com

6. **remove.bg**
   - Best for: Quick background removal
   - URL: remove.bg

**Recommended Workflow**: Leonardo.AI for generation + Photopea for editing

---

### POC Asset Creation: Detailed Steps

For each asset type, we'll follow this pattern:
1. **Generate** with AI tool (Leonardo.AI)
2. **Edit** in Photopea (remove background, adjust size, add transparency)
3. **Create variations** (recolors, animation frames)
4. **Export** as PNG with proper dimensions
5. **Integrate** into Godot project

---

## POC Asset List (Minimum Viable Design)

### Heroes (2 Total)
1. **Arcane Wanderer** - Ranged magic user
2. **Shadow Knight** - Melee warrior

### Monsters (2 Total)
1. **Sand Grunt** - Basic melee enemy
2. **Night Wraith** - Floating magical enemy

### Weapons
1. **Arcane Wand** - Magic projectile weapon
2. **Fire Staff** - Flame projectile weapon

### Projectiles
1. **Arcane Spark** - Blue magic bolt
2. **Fireball** - Orange fire projectile

### Environmental Objects (4 Total)
1. **Dark Tree** - Obstacle
2. **Glowing Crystal** - Interactive prop
3. **Tombstone** - Decorative obstacle
4. **Nightfall Arena Background** - Main game background

---

## Detailed Task List

### Phase 1: Code Infrastructure Setup

**Estimated Time**: 4-6 hours

#### Task 1.1: Create New Asset Directory Structure
- [ ] Create folders under `game/assets/` following proposed structure
  - `characters/heroes/arcane_wanderer/`
  - `characters/heroes/shadow_knight/`
  - `characters/monsters/sand_grunt/`
  - `characters/monsters/night_wraith/`
  - `projectiles/magic/`
  - `projectiles/fire/`
  - `weapons/icons/`
  - `environment/props/`
  - `environment/backgrounds/`
  - `environment/particles/`

**Commands**:
```bash
cd game/assets
mkdir -p characters/heroes/{arcane_wanderer,shadow_knight}
mkdir -p characters/monsters/{sand_grunt,night_wraith}
mkdir -p projectiles/{magic,fire}
mkdir -p weapons/icons
mkdir -p environment/{props,backgrounds,particles}
```

---

#### Task 1.2: Update VisualGameObject for AnimatedSprite2D
**File**: `game/scripts/core/visual_game_object.gd`

- [ ] Add `@export var use_animated_sprite := false`
- [ ] Add `@export var sprite_frames : SpriteFrames`
- [ ] Modify `_find_or_create_sprite()` to support both sprite types
- [ ] Add `play_animation()` method
- [ ] Add `stop_animation()` method

**Acceptance Criteria**:
- Objects can use either Sprite2D or AnimatedSprite2D
- No breaking changes to existing scenes
- Animation playback works correctly

---

#### Task 1.3: Add Animation State Management to Character
**File**: `game/scripts/characters/character.gd`

- [ ] Add `AnimState` enum (IDLE, WALK, ATTACK, HURT, DEATH)
- [ ] Add `current_anim_state` variable
- [ ] Implement `_update_animation_state()` method
- [ ] Call animation updates in `_physics_process()`

**Acceptance Criteria**:
- Characters automatically transition between idle/walk animations
- Attack/hurt/death animations can be triggered by events

---

#### Task 1.4: Create Shader Resources
**Files**: New shader files in `game/shaders/`

- [ ] Create `projectile_glow.gdshader` with pulsing emission effect
- [ ] Create `hit_flash.gdshader` for damage feedback
- [ ] Create `outline.gdshader` for selection/targeting
- [ ] Test each shader with dummy sprites

**Acceptance Criteria**:
- Shaders compile without errors
- Parameters are accessible from GDScript
- Visual effects work as expected

---

#### Task 1.5: Create Particle Effect Templates
**Files**: New scenes in `game/scenes/effects/particle_templates/`

- [ ] Create `magic_trail.tscn` - Blue magic trail particles
- [ ] Create `fire_trail.tscn` - Orange fire trail particles
- [ ] Create `magic_impact.tscn` - Blue burst on impact
- [ ] Create `fire_explosion.tscn` - Fire explosion effect

**Acceptance Criteria**:
- Particles look good and perform well
- Effects have appropriate lifetime
- Colors match theme palette

---

#### Task 1.6: Update ProjectileBase for New Effects
**File**: `game/scripts/projectiles/projectile_base.gd`

- [ ] Add `@export var trail_particles : PackedScene`
- [ ] Add `@export var use_glow_shader := false`
- [ ] Add `@export var glow_texture : Texture2D`
- [ ] Implement trail particle spawning in `_ready()`
- [ ] Implement particle cleanup on impact

**Acceptance Criteria**:
- Projectiles can spawn trail particles
- Particles clean up properly when projectile is destroyed
- Shader material can be applied to projectile sprites

---

#### Task 1.7: Update Catalog Schema
**File**: `game/config/data/objects/catalog.json`

- [ ] Add `use_animated_sprite` to hero properties
- [ ] Add `sprite_frames` reference to hero properties
- [ ] Add `sprite_texture` to projectile properties
- [ ] Add `trail_particles` to projectile properties
- [ ] Add `portrait` to hero metadata

**Acceptance Criteria**:
- Catalog validates with new fields
- Factory can read and apply new properties
- Backward compatible with existing entries

---

#### Task 1.8: Create Import Preset for Assets
**File**: `game/.godot/import_presets.cfg` or manual configuration

- [ ] Set up import settings for character sprites (lossless, no filter)
- [ ] Set up import settings for particle textures (compressed, filtered)
- [ ] Set up import settings for UI icons (lossless, filtered)
- [ ] Document import settings in README or wiki

**Acceptance Criteria**:
- Assets import with optimal quality/performance balance
- Pixel art remains crisp
- Particles look smooth

---

### Phase 2: POC Asset Creation with AI Tools

**Estimated Time**: 8-12 hours (including learning AI tools)

#### General Workflow for Each Asset:
1. Generate concept with Leonardo.AI
2. Remove background using remove.bg
3. Edit in Photopea (resize, transparency, adjustments)
4. Export as PNG
5. Import to Godot
6. Create necessary resources (SpriteFrames, ShaderMaterial, etc.)
7. Update catalog entry
8. Test in-game

---

### Task 2.1: Create Hero 1 - Arcane Wanderer

**Deliverables**: Static sprite + portrait icon

#### Step 2.1.1: Generate Concept Art
**Tool**: Leonardo.AI

**Prompt**:
```
Top-down view 2D game character sprite, arcane wanderer mage, wearing flowing midnight blue robes with glowing cyan runes, holding a magical staff with crystal orb, dark fantasy style, mystical aura, transparent background, single character centered, pixel art inspired but detailed, nightfall survivor game aesthetic, glowing arcane energy effects
```

**Settings**:
- Model: Leonardo Diffusion XL or Anime Pastel Dream
- Dimensions: 512x512
- Number of images: 4 (pick best)

**Output**: `arcane_wanderer_concept.png`

---

#### Step 2.1.2: Create Game-Ready Sprite

1. **Clean up in Photopea**:
   - Open `arcane_wanderer_concept.png` in Photopea
   - Use Magic Wand (W) to select and delete background if needed
   - Go to Image > Canvas Size: Set to 256x256 (character centered)
   - Layer > New Adjustment Layer > Hue/Saturation (fine-tune colors)
   - Export as PNG with transparency

2. **Save as**: `game/assets/characters/heroes/arcane_wanderer/idle_static.png`

---

#### Step 2.1.3: Create Portrait Icon

1. **In Photopea**:
   - Duplicate the character sprite
   - Crop to head/upper torso
   - Image > Canvas Size: 256x256
   - Add dark circular background layer behind character
   - Add subtle glow effect (Layer > Layer Styles > Outer Glow)

2. **Save as**: `game/assets/characters/heroes/arcane_wanderer/portrait.png`

---

#### Step 2.1.4: Integrate into Godot

1. Import both PNGs into Godot
2. Update `game/scenes/player.tscn`:
   - Set Sprite2D texture to `idle_static.png`
   - Adjust scale if needed (around 0.6-0.8)
3. Update catalog entry for `hero_arcane`:
   ```json
   "properties": {
     "sprite_texture": "res://assets/characters/heroes/arcane_wanderer/idle_static.png"
   },
   "metadata": {
     "icon": "res://assets/characters/heroes/arcane_wanderer/portrait.png"
   }
   ```

4. **Test**: Run game, verify hero sprite loads correctly

**Checklist**:
- [ ] Concept generated in Leonardo.AI
- [ ] Background removed
- [ ] Sprite edited to 256x256 in Photopea
- [ ] Portrait created at 256x256
- [ ] Both PNGs exported with transparency
- [ ] Assets imported into Godot
- [ ] Player scene updated
- [ ] Catalog updated
- [ ] Tested in-game

---

### Task 2.2: Create Hero 2 - Shadow Knight

**Deliverables**: Static sprite + portrait icon

#### Step 2.2.1: Generate Concept Art
**Tool**: Leonardo.AI

**Prompt**:
```
Top-down view 2D game character sprite, shadow knight warrior, wearing dark heavy plate armor with crimson accents, wielding a large glowing sword, dark fantasy style, menacing presence, transparent background, single character centered, pixel art inspired but detailed, nightfall survivor game aesthetic, shadow energy aura
```

**Settings**: Same as Task 2.1.1

**Output**: `shadow_knight_concept.png`

#### Follow same workflow as Task 2.1 (steps 2-4)

**Save locations**:
- `game/assets/characters/heroes/shadow_knight/idle_static.png`
- `game/assets/characters/heroes/shadow_knight/portrait.png`

**Catalog entry**:
```json
{
  "hero_shadow": {
    "type": "hero",
    "id": "hero_shadow",
    "name": "Shadow Knight",
    "scene": "res://scenes/player.tscn",
    "properties": {
      "max_health": 180,
      "move_speed": 280,
      "base_damage": 20,
      "sprite_texture": "res://assets/characters/heroes/shadow_knight/idle_static.png"
    },
    "metadata": {
      "icon": "res://assets/characters/heroes/shadow_knight/portrait.png",
      "description": "Armored warrior who thrives in close combat."
    }
  }
}
```

**Checklist**:
- [ ] Concept generated
- [ ] Sprite created (256x256)
- [ ] Portrait created (256x256)
- [ ] Assets exported and imported
- [ ] Catalog entry added
- [ ] Tested by swapping in player scene

---

### Task 2.3: Create Monster 1 - Sand Grunt

**Deliverables**: Static sprite

#### Step 2.3.1: Generate Concept
**Tool**: Leonardo.AI

**Prompt**:
```
Top-down view 2D game enemy sprite, sand grunt creature, small goblin-like monster with sandy brown skin, crude weapons, hunched posture, desert wasteland aesthetic, dark fantasy style, hostile appearance, transparent background, single character centered, nightfall survivor game style
```

**Dimensions**: 256x256

#### Step 2.3.2: Process and Save
- Clean up in Photopea
- Resize to 128x128 (enemies are smaller than heroes)
- **Save as**: `game/assets/characters/monsters/sand_grunt/idle_static.png`

#### Step 2.3.3: Update Catalog
```json
{
  "monster_grunt": {
    "type": "monster",
    "id": "monster_grunt",
    "name": "Sand Grunt",
    "scene": "res://scenes/enemy.tscn",
    "properties": {
      "max_health": 60,
      "move_speed": 180,
      "base_damage": 8,
      "sprite_texture": "res://assets/characters/monsters/sand_grunt/idle_static.png"
    }
  }
}
```

#### Step 2.3.4: Update Enemy Scene
- Modify `game/scenes/enemy.tscn`
- Update Sprite2D texture to new asset
- Adjust scale (around 0.5)

**Checklist**:
- [ ] Concept generated
- [ ] Sprite created (128x128)
- [ ] Asset exported and imported
- [ ] Enemy scene updated
- [ ] Catalog updated
- [ ] Tested with enemy spawner

---

### Task 2.4: Create Monster 2 - Night Wraith

**Deliverables**: Static sprite with transparency/ghostly effect

#### Step 2.4.1: Generate Concept
**Tool**: Leonardo.AI

**Prompt**:
```
Top-down view 2D game enemy sprite, night wraith spirit, floating ghost-like creature, ethereal dark purple and cyan glow, spectral energy wisps, no legs (hovering), sinister appearance, dark fantasy style, transparent background, single character centered, nightfall survivor game aesthetic, magical aura
```

**Dimensions**: 256x256

#### Step 2.4.2: Add Transparency Effect
- Process in Photopea
- Reduce layer opacity to 80% for ghostly appearance
- Add soft outer glow (cyan/purple)
- Resize to 128x128
- **Save as**: `game/assets/characters/monsters/night_wraith/idle_static.png`

#### Step 2.4.3: Apply Glow Shader
Since this is a magical enemy, we can apply the glow shader:

1. Create shader material in Godot
2. Assign `projectile_glow.gdshader` to night wraith sprite
3. Set shader parameters:
   ```gdscript
   glow_color = Color(0.6, 0.4, 1.0, 1.0)  # Purple glow
   glow_intensity = 1.8
   pulse_speed = 1.5
   ```

#### Step 2.4.4: Update Catalog
```json
{
  "monster_wraith": {
    "type": "monster",
    "id": "monster_wraith",
    "name": "Night Wraith",
    "scene": "res://scenes/enemy.tscn",
    "properties": {
      "max_health": 45,
      "move_speed": 220,
      "base_damage": 12,
      "sprite_texture": "res://assets/characters/monsters/night_wraith/idle_static.png",
      "use_glow_shader": true
    }
  }
}
```

**Checklist**:
- [ ] Concept generated
- [ ] Sprite created with ghostly transparency
- [ ] Glow shader applied
- [ ] Asset imported
- [ ] Catalog updated
- [ ] Tested in-game (should glow and pulse)

---

### Task 2.5: Create Weapon Icons (2 Total)

#### Task 2.5.1: Arcane Wand Icon

**Prompt**:
```
Game UI icon, arcane wand weapon, magical staff with glowing blue crystal orb, intricate runic details, dark background, fantasy game item, centered composition, detailed illustration, icon art style, 256x256, nightfall survivor aesthetic
```

**Process**:
- Generate in Leonardo.AI
- Add dark circular or square background in Photopea
- Add subtle border/frame
- Resize to 256x256
- **Save as**: `game/assets/weapons/icons/arcane_wand.png`

**Update Catalog**:
```json
{
  "weapon_arcane_wand": {
    "metadata": {
      "icon": "res://assets/weapons/icons/arcane_wand.png"
    }
  }
}
```

---

#### Task 2.5.2: Fire Staff Icon

**Prompt**:
```
Game UI icon, fire staff weapon, magical staff with burning flame at the top, ember glow, dark background, fantasy game item, centered composition, detailed illustration, icon art style, 256x256, nightfall survivor aesthetic, orange and red colors
```

**Process**: Same as 2.5.1
**Save as**: `game/assets/weapons/icons/fire_staff.png`

**Checklist**:
- [ ] Arcane wand icon generated and processed
- [ ] Fire staff icon generated and processed
- [ ] Both icons at 256x256 with backgrounds
- [ ] Assets imported
- [ ] Catalog updated for both weapons
- [ ] Icons visible in game UI (weapon selection)

---

### Task 2.6: Create Projectile Assets

#### Task 2.6.1: Arcane Spark (Complete Set)

We need 3 assets for this projectile:
1. Base sprite
2. Trail particle texture
3. Impact effect sprite sheet

---

**Part A: Base Sprite**

**Prompt**:
```
Game sprite, magical arcane energy projectile, blue glowing orb with sparkles, mystical particle effects, transparent background, centered, 128x128, dark fantasy game art, cyan and blue colors, nightfall survivor style
```

**Process**:
- Generate in Leonardo.AI
- Clean in Photopea, resize to 64x64
- **Save as**: `game/assets/projectiles/magic/arcane_spark_base.png`

---

**Part B: Trail Particle Texture**

**Prompt**:
```
Particle texture, small magical sparkle, blue glowing wisp, soft edges, transparent background, single particle, 64x64, cyan glow, game particle effect
```

**Process**:
- Generate small sparkle/wisp
- Make edges very soft/transparent (Gaussian blur)
- Resize to 32x32
- **Save as**: `game/assets/projectiles/magic/arcane_spark_trail.png`

---

**Part C: Glow Map (for shader)**

**In Photopea**:
- Duplicate `arcane_spark_base.png`
- Desaturate (Image > Adjustments > Desaturate)
- Increase contrast (bright center, dark edges)
- This becomes the emission mask
- **Save as**: `game/assets/projectiles/magic/arcane_spark_glow.png`

---

**Part D: Impact Effect (4-frame sprite sheet)**

**Prompt**:
```
Sprite sheet, magical impact explosion sequence, 4 frames, blue arcane energy burst expanding outward, sparkles dispersing, transparent background, grid layout, game VFX, nightfall survivor style, 512x128 (4x 128x128 frames side by side)
```

**Alternative approach** (if sprite sheet generation fails):
- Generate single impact frame
- Duplicate and scale up in Photopea to create 4 frames
- Arrange in horizontal sprite sheet

**Process**:
- Resize to 512x128 (or 256x64 for smaller effect)
- Each frame should show impact growing then fading
- **Save as**: `game/assets/projectiles/magic/arcane_spark_impact.png`

---

**Part E: Create Impact AnimatedSprite2D Resource**

**In Godot**:
1. Create new SpriteFrames resource
2. Import impact sprite sheet
3. Use "Add Frames from Sprite Sheet" option
4. Configure grid: 4 columns x 1 row
5. Set animation speed: 12 FPS
6. Set loop: false (one-shot)
7. **Save as**: `game/assets/projectiles/magic/arcane_impact_frames.tres`

---

**Part F: Create Impact Scene**

**File**: `game/scenes/effects/arcane_impact.tscn`

```
AnimatedSprite2D (Impact Effect)
├── sprite_frames: arcane_impact_frames.tres
├── animation: "default"
├── autoplay: "" (controlled by script)
└── script: impact_effect.gd

# impact_effect.gd
extends AnimatedSprite2D

func _ready() -> void:
    play()
    animation_finished.connect(_on_finished)

func _on_finished() -> void:
    queue_free()  # Remove after animation completes
```

---

**Part G: Update Projectile Scene**

**File**: `game/scenes/projectiles/magic_spark_projectile.tscn`

Add shader material to Sprite2D:
```
[node name="Sprite2D" type="Sprite2D" parent="."]
texture = ExtResource("arcane_spark_base.png")
material = ShaderMaterial
    shader = ExtResource("projectile_glow.gdshader")
    shader_parameters:
        glow_map = ExtResource("arcane_spark_glow.png")
        glow_color = Color(0.5, 0.8, 1.0, 1.0)
        glow_intensity = 2.0
        pulse_speed = 3.0
```

Update script properties:
```gdscript
@export var trail_particles : PackedScene = preload("res://scenes/effects/particles/arcane_trail.tscn")
@export var on_impact_effect : PackedScene = preload("res://scenes/effects/arcane_impact.tscn")
```

---

**Part H: Create Trail Particle Scene**

**File**: `game/scenes/effects/particles/arcane_trail.tscn`

```
GPUParticles2D
├── amount: 16
├── lifetime: 0.4
├── preprocess: 0.1
├── process_material: ParticleProcessMaterial
│   ├── emission_shape: Point
│   ├── direction: Vector3(0, 0, 0)
│   ├── spread: 30.0
│   ├── initial_velocity_min: 10.0
│   ├── initial_velocity_max: 30.0
│   ├── gravity: Vector3(0, 0, 0)
│   ├── scale_min: 0.4
│   ├── scale_max: 0.8
│   ├── color: Color(0.5, 0.8, 1.0, 1.0)
│   └── color_ramp: [Gradient fading to transparent]
└── texture: arcane_spark_trail.png
```

---

**Checklist for Arcane Spark**:
- [ ] Base sprite generated and saved (64x64)
- [ ] Trail particle texture created (32x32)
- [ ] Glow map created from base sprite
- [ ] Impact sprite sheet generated (4 frames)
- [ ] Impact SpriteFrames resource created
- [ ] Impact scene with AnimatedSprite2D created
- [ ] Trail particle scene created
- [ ] Shader material applied to projectile
- [ ] All assets imported and linked
- [ ] Tested in-game (shoot projectile, see glow, trail, and impact)

---

#### Task 2.6.2: Fireball (Complete Set)

Follow the exact same workflow as Task 2.6.1, but with fire theme:

**Color Palette**: Orange (1.0, 0.5, 0.1), Red (1.0, 0.2, 0.0), Yellow (1.0, 0.8, 0.2)

**Prompts** (adjust from arcane versions):
- Base: "fire projectile, burning fireball, orange and red flames..."
- Trail: "fire particle, ember, orange glow..."
- Impact: "fire explosion, flames bursting outward, 4 frames..."

**Save locations**:
- `game/assets/projectiles/fire/fireball_base.png` (64x64)
- `game/assets/projectiles/fire/fireball_trail.png` (32x32)
- `game/assets/projectiles/fire/fireball_glow.png` (64x64)
- `game/assets/projectiles/fire/fireball_impact.png` (sprite sheet)

**Shader parameters**:
```gdscript
glow_color = Color(1.0, 0.5, 0.1, 1.0)  # Orange
glow_intensity = 2.5
pulse_speed = 4.0  # Faster flicker for fire
```

**Checklist for Fireball**:
- [ ] All 4 assets created (base, trail, glow, impact)
- [ ] Fire trail particle scene created
- [ ] Fire impact effect scene created
- [ ] Shader applied with orange glow
- [ ] Fireball projectile scene updated
- [ ] Tested in-game

---

### Task 2.7: Create Environmental Objects

#### Task 2.7.1: Dark Tree

**Prompt**:
```
Top-down view, dark fantasy game environment, dead tree with twisted branches, dark bark, nightfall setting, transparent background, 2D game sprite, detailed but stylized, 512x512, nightfall survivor aesthetic, ominous atmosphere
```

**Process**:
- Generate in Leonardo.AI
- Clean up in Photopea
- Resize to appropriate size (tree can be 256x256 or 384x384)
- Ensure good transparency around branches
- **Save as**: `game/assets/environment/props/tree_dark.png`

**Create scene**: `game/scenes/environment/tree_obstacle.tscn`
```
StaticBody2D (or use ImmovableObject script)
├── Sprite2D
│   └── texture: tree_dark.png
└── CollisionShape2D
    └── shape: CircleShape2D (radius ~40, trunk only)
```

**Checklist**:
- [ ] Tree sprite generated
- [ ] Background removed, transparency clean
- [ ] Asset imported
- [ ] Obstacle scene created
- [ ] Collision shape configured
- [ ] Tested in-game (blocks player movement)

---

#### Task 2.7.2: Glowing Crystal

**Prompt**:
```
Top-down view, glowing magical crystal formation, blue-cyan luminescent gem, dark fantasy setting, transparent background, 2D game sprite, mystical energy, detailed crystal facets, 256x256, nightfall survivor style
```

**Process**:
- Generate and clean
- Resize to 128x128 or 192x192
- **Save as**: `game/assets/environment/props/crystal_blue.png`

**Apply glow shader** for visual effect:
```gdscript
# In crystal scene
material = ShaderMaterial (glow shader)
glow_color = Color(0.4, 0.8, 1.0, 1.0)
glow_intensity = 2.0
pulse_speed = 1.0
```

**Checklist**:
- [ ] Crystal sprite generated
- [ ] Glow shader applied
- [ ] Scene created (can be NonInteractableObject or Collectible)
- [ ] Tested in-game (should pulse with glow)

---

#### Task 2.7.3: Tombstone

**Prompt**:
```
Top-down view, old weathered tombstone, cracked stone, dark fantasy graveyard, moss covered, transparent background, 2D game sprite, detailed stone texture, 256x256, nightfall survivor aesthetic
```

**Process**: Same as tree
**Save as**: `game/assets/environment/props/tombstone.png`
**Size**: 128x128 to 192x192

**Checklist**:
- [ ] Tombstone sprite generated and cleaned
- [ ] Obstacle scene created
- [ ] Collision configured
- [ ] Tested in-game

---

#### Task 2.7.4: Nightfall Arena Background

This is the most important environmental asset.

**Prompt**:
```
Top-down view background for 2D game, dark fantasy arena, nightfall setting, cracked ground with mystical runes, dark purple sky, scattered rocks and debris, atmospheric fog, seamless tileable texture if possible, 2048x2048, nightfall survivor game aesthetic, ominous and mystical
```

**Alternative approach** (if too complex):
Generate smaller 512x512 tileable ground texture and use TileMap

**Process**:
1. Generate large background (2048x2048 or 1920x1080)
2. Adjust levels/curves in Photopea for darker atmosphere
3. Add vignette effect (darken edges)
4. **Save as**: `game/assets/environment/backgrounds/nightfall_arena.png`

**Update Main Scene**:
```gdscript
# In game/scenes/main.tscn
[node name="Background" type="Sprite2D" parent="World"]
z_index = -100
texture = ExtResource("nightfall_arena.png")
centered = true
```

**Checklist**:
- [ ] Background generated (large resolution)
- [ ] Edited for proper atmosphere
- [ ] Asset imported
- [ ] Main scene background updated
- [ ] Tested in-game (should cover entire play area)

---

### Phase 3: Integration and Testing

**Estimated Time**: 2-4 hours

#### Task 3.1: Update All Catalog Entries
- [ ] Verify all hero entries point to new sprites and icons
- [ ] Verify all monster entries point to new sprites
- [ ] Verify all projectile entries reference new assets and effects
- [ ] Verify all weapon entries have new icons

**Test**: Load game, check that ObjectCatalog creates objects with correct visuals

---

#### Task 3.2: Scene Configuration
- [ ] Update player scene with new hero sprite
- [ ] Update enemy scene with new monster sprite
- [ ] Update all projectile scenes with new assets and shaders
- [ ] Verify all collision shapes still match new sprite sizes

**Test**: Spawn each object type manually, verify appearance

---

#### Task 3.3: Shader and Effect Testing
- [ ] Test projectile glow shaders (both arcane and fire)
- [ ] Test character hit flash shader (damage feedback)
- [ ] Test particle trails (spawn projectiles, verify trails appear)
- [ ] Test impact effects (projectiles hitting enemies)

**Test**: Run game, shoot projectiles at enemies, verify all VFX work

---

#### Task 3.4: Performance Testing
- [ ] Spawn 50+ enemies, check frame rate
- [ ] Fire multiple projectiles simultaneously
- [ ] Verify particle systems don't cause lag
- [ ] Check GPU usage in Godot profiler

**Acceptance Criteria**: Game maintains 60 FPS with all new assets

---

#### Task 3.5: Visual Consistency Check
- [ ] All assets use consistent color palette (purples, blues, dark tones)
- [ ] Heroes and monsters have similar art style
- [ ] Projectiles match weapon themes
- [ ] Environment props fit arena theme

**Acceptance Criteria**: Game looks cohesive, not like mismatched assets

---

#### Task 3.6: Documentation
- [ ] Document the full asset creation workflow
- [ ] Create template prompts for future assets
- [ ] Update README with new asset pipeline
- [ ] Add screenshots of completed POC to docs

---

## AI Tools Workflow Summary

### Leonardo.AI Quick Start

1. **Sign up**: Go to leonardo.ai, create free account
2. **Select model**:
   - "Leonardo Diffusion XL" for realistic fantasy
   - "Anime Pastel Dream" for stylized/anime look
   - "DreamShaper" for versatile results
3. **Image dimensions**: Always use 512x512 or 1024x1024 for best quality
4. **Generate multiple**: Create 4 images per prompt, pick best
5. **Refine**: Use "Prompt Magic" toggle for enhanced results
6. **Download**: Save images as PNG

### Photopea Workflow

1. **Open file**: Drag PNG into photopea.com
2. **Remove background** (if needed):
   - Magic Wand tool (W)
   - Click background
   - Delete
3. **Resize**:
   - Image > Canvas Size
   - Set dimensions (center anchor)
4. **Adjust colors**:
   - Layer > New Adjustment Layer > Hue/Saturation
   - Tweak until matching palette
5. **Add effects**:
   - Layer > Layer Style > Outer Glow (for crystals, magic items)
6. **Export**:
   - File > Export As > PNG
   - Check "Transparency"

### remove.bg Alternative

If Photopea background removal is difficult:
1. Go to remove.bg
2. Upload image
3. Download result (free for low-res, $0.20 for high-res)
4. Open in Photopea for further editing

---

## Variant Strategies

### Option A: Minimal POC (Fastest)
- **Time**: 6-8 hours total
- Create only static sprites (no animations)
- Use simple particle effects (built-in Godot particles, no custom textures)
- Use color modulation instead of unique sprites for projectile variants
- Skip shaders initially

**Best for**: Quick visual upgrade to test if style works

---

### Option B: Polished POC (Recommended)
- **Time**: 12-16 hours total
- Static sprites with high-quality art
- Custom particle textures and shaders
- Unique sprites for each projectile type
- Professional UI icons

**Best for**: Production-ready baseline, can expand from here

---

### Option C: Animated POC (Most Complete)
- **Time**: 20-30 hours total
- Animated sprites (idle, walk, attack for heroes and monsters)
- Full particle systems with custom textures
- All shaders implemented
- Sprite sheets and texture atlases

**Best for**: If you have time and want near-final quality

---

## Troubleshooting

### Issue: AI generates inconsistent art styles
**Solution**:
- Use the same model/settings for all assets
- Reference previous images in prompts: "in the style of this image" (upload previous)
- Use Leonardo's "Image Guidance" feature to maintain consistency

### Issue: Backgrounds aren't transparent
**Solution**:
- Add "transparent background, alpha channel" to prompts
- Use remove.bg for automated removal
- Manually remove in Photopea with Magic Wand + Delete

### Issue: Sprites are wrong size in Godot
**Solution**:
- Set scale in scene files (typical: 0.5-0.8 for characters)
- Or resize assets before importing (heroes: 256x256, monsters: 128x128)

### Issue: Shaders not appearing
**Solution**:
- Verify shader compiles (check Godot console for errors)
- Ensure glow map texture is assigned
- Check that ShaderMaterial is attached to Sprite2D, not parent node

### Issue: Particles cause performance drops
**Solution**:
- Reduce particle amount (16-32 max for trails)
- Decrease lifetime (0.3-0.5 seconds)
- Use "Local Coords" mode in particle system
- Consider using CPUParticles2D for mobile

---

## Next Steps After POC

Once POC is complete and validated:

1. **Expand roster**:
   - Add 3-5 more heroes with unique sprites
   - Add 5-10 more monster types

2. **Create animations**:
   - Generate sprite sheets for idle/walk/attack
   - Implement AnimatedSprite2D for all characters

3. **Advanced effects**:
   - Screen shake on impacts
   - Camera effects for special abilities
   - More complex particle systems (weather, environmental effects)

4. **UI polish**:
   - Animated menu backgrounds
   - Custom fonts matching theme
   - Icon animations and hover effects

5. **Sound design**:
   - Pair visuals with SFX using AI tools (ElevenLabs, Soundraw)

---

## Estimated Total Time

| Phase | Minimum | Recommended | Maximum |
|-------|---------|-------------|---------|
| Code Infrastructure | 4 hours | 6 hours | 8 hours |
| Asset Creation | 6 hours | 10 hours | 20 hours |
| Integration & Testing | 2 hours | 3 hours | 5 hours |
| **TOTAL** | **12 hours** | **19 hours** | **33 hours** |

**Recommendation**: Start with Option B (Polished POC), budget 2-3 full days of work.

---

## Summary Checklist

### Code Changes
- [ ] Asset directory structure created
- [ ] AnimatedSprite2D support added to VisualGameObject
- [ ] Animation state management in Character class
- [ ] 3 shaders created (glow, hit flash, outline)
- [ ] 4 particle effect templates created
- [ ] ProjectileBase updated for particles and shaders
- [ ] Catalog schema updated
- [ ] Import presets configured

### Assets Created
- [ ] Hero 1: Arcane Wanderer (sprite + portrait)
- [ ] Hero 2: Shadow Knight (sprite + portrait)
- [ ] Monster 1: Sand Grunt (sprite)
- [ ] Monster 2: Night Wraith (sprite + shader)
- [ ] Weapon Icon 1: Arcane Wand
- [ ] Weapon Icon 2: Fire Staff
- [ ] Projectile 1: Arcane Spark (base, trail, glow, impact)
- [ ] Projectile 2: Fireball (base, trail, glow, impact)
- [ ] Prop 1: Dark Tree
- [ ] Prop 2: Glowing Crystal
- [ ] Prop 3: Tombstone
- [ ] Background: Nightfall Arena

### Integration
- [ ] All catalog entries updated
- [ ] All scenes configured with new assets
- [ ] Shaders applied and tested
- [ ] Particles working correctly
- [ ] Performance validated
- [ ] Visual consistency confirmed
- [ ] Documentation updated

---

**End of Visual Upgrade Plan**

This plan should give you a complete roadmap from current SVG placeholders to production-quality game assets. Start with Phase 1 (code infrastructure), then move to Phase 2 (asset creation), and finish with Phase 3 (integration). Good luck!
