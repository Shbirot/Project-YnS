# Object Hierarchy Refactor - Performance-First Design

## Executive Summary

The current object hierarchy uses rigid binary splits (movable/immovable, interactable/non-interactable) that don't support hybrid objects needed for a bullet-heaven game. This document proposes a **flexible, performance-first hierarchy** using strategic inheritance, collision layers, and object pooling.

## Current Hierarchy Analysis

### Current Structure

```
CharacterBody2D (Godot base - heavy physics object)
└── VisualGameObject (sprite, enable/disable)
    ├── MovableGameObject (velocity-based movement)
    │   └── Character (HP, damage, signals)
    │       ├── HeroCharacter (player input, auto-aim)
    │       └── MonsterCharacter (AI seek behavior)
    ├── InteractableObject (interaction signals)
    │   └── Collectible (pickups)
    └── NonInteractableObject (empty marker)
        └── ImmovableObject (obstacles with collision)
```

### Identified Issues

#### 1. **Binary Splits are Too Rigid**
- `InteractableObject` vs `NonInteractableObject` - but interaction might be contextual or conditional
- `MovableGameObject` vs `ImmovableObject` in different branches - inconsistent categorization
- **Can't express**: Moving interactables (coins that roll), moving non-interactables (clouds), static interactables (NPCs)

#### 2. **Collision/Physics Not Explicitly Modeled**
- All extend `CharacterBody2D` - even decorative elements that don't need physics
- Physical vs transparent collision is not a first-class design concern
- Collision layers/masks not part of the architecture
- **Performance impact**: Unnecessary physics processing for hundreds of objects

#### 3. **Movement Capabilities Mixed**
- `MovableGameObject` only supports simple velocity-based movement
- No support for:
  - Scripted paths (clouds moving in patterns)
  - Physics-only movement (coins rolling with inertia)
  - Hybrid movement (enemy with pathfinding + physics)

#### 4. **Multiple Inheritance Problem**
Want to express combinations:
- Moving + Interactable (rolling coins)
- Moving + Transparent (background clouds)
- Static + Interactable (stationary NPCs)
- Static + Physical (obstacles)
- Moving + Physical + Interactable (physics-based pickups)

Current hierarchy forces you to choose **one path**, duplicating code across branches.

#### 5. **Performance Concerns for Bullet-Heaven Genre**

Bullet-heaven games require:
- **100-300+ entities on screen** (enemies, projectiles, pickups, effects)
- **60 FPS minimum** even on mid-range hardware
- **Minimal GC pressure** (no excessive allocations)
- **Efficient spatial queries** (collision, targeting)

Current issues:
- Everything extends `CharacterBody2D` (physics processing even for decorations)
- No object pooling system
- No explicit performance tiers (critical vs decorative objects)

## Design Goals

### 1. Performance First
- Minimize node count in scene tree
- Pool frequently created objects (enemies, projectiles, coins)
- Separate rendering from physics processing
- Use collision layers/masks for interaction logic
- Static systems for cross-entity operations

### 2. Flexibility
- Support hybrid objects (moving + interactable, etc.)
- Easy to add new object types without deep refactoring
- Composition where beneficial, inheritance where performant

### 3. Maintainability
- Clear, logical categorization
- Minimal code duplication
- Well-defined interfaces
- Easy to understand at a glance

### 4. Scalability
- Designed for 300+ concurrent entities
- Graceful degradation on lower-end hardware
- Performance monitoring built-in

## Proposed Architecture

### Core Principle: Multi-Dimensional Properties, Not Binary Splits

Instead of inheritance-based splits, define objects by **orthogonal properties**:

1. **Physics Mode**: How does it interact with the physics engine?
   - `NONE`: No physics (pure visual, UI elements)
   - `STATIC`: Collision but no movement (walls, trees)
   - `KINEMATIC`: Scripted movement (player, enemies, clouds)
   - `DYNAMIC`: Physics-driven (coins, physics objects)

2. **Collision Mode**: What type of collision?
   - `NONE`: No collision (background decorations)
   - `PHYSICAL`: Blocks movement (walls, obstacles)
   - `SENSOR`: Detects overlap only (pickups, trigger zones)
   - `MIXED`: Both physical body + sensor area

3. **Movement Mode**: How does it move?
   - `STATIC`: Never moves
   - `VELOCITY`: Direct velocity control (most characters)
   - `PATH`: Follows a path (scripted clouds, moving platforms)
   - `PHYSICS`: Governed by physics forces (rolling objects)
   - `AI`: AI-controlled movement

4. **Interaction Type**: How can players interact?
   - `NONE`: No interaction
   - `COLLECTIBLE`: Auto-collect on overlap (coins, powerups)
   - `TRIGGERABLE`: One-time activation (chests, switches)
   - `CONVERSABLE`: Dialogue/menu interaction (NPCs, shops)
   - `CUSTOM`: Complex custom logic

5. **Render Tier**: Performance priority
   - `CRITICAL`: Always render (player, enemies)
   - `IMPORTANT`: Render if on-screen (projectiles, effects)
   - `DECORATIVE`: Can skip if performance drops (particles, clouds)

### New Hierarchy Structure

```
GameObject (base - Node2D or CharacterBody2D chosen at instantiation)
│
├── Properties (enums):
│   ├── physics_mode: PhysicsMode
│   ├── collision_mode: CollisionMode
│   ├── movement_mode: MovementMode
│   ├── interaction_type: InteractionType
│   └── render_tier: RenderTier
│
├── Core Components (built-in):
│   ├── sprite: Sprite2D (lazy-created)
│   ├── collision_shape: CollisionShape2D (if needed)
│   ├── interaction_area: Area2D (if interactable)
│   └── stats: Dictionary (HP, speed, damage, etc.)
│
├── Poolable Interface:
│   ├── reset() -> void
│   ├── activate() -> void
│   └── deactivate() -> void
│
└── Lifecycle Hooks:
    ├── _on_spawn()
    ├── _on_despawn()
    ├── _on_enable()
    └── _on_disable()

Common Subclasses (for convenience and shared behavior):

PhysicsEntity (physics_mode: KINEMATIC, collision_mode: PHYSICAL)
├── Character (adds HP, damage, signals)
│   ├── HeroCharacter (player input, auto-aim)
│   └── MonsterCharacter (AI behavior)
└── PhysicsCollectible (collision_mode: DYNAMIC, interaction: COLLECTIBLE)

StaticEntity (physics_mode: STATIC)
├── Obstacle (collision_mode: PHYSICAL)
├── Collectible (collision_mode: SENSOR, interaction: COLLECTIBLE)
├── Trigger (collision_mode: SENSOR, interaction: TRIGGERABLE)
└── Decoration (collision_mode: NONE, render_tier: DECORATIVE)

ProjectileEntity (optimized for bullets)
└── ProjectileBase (existing implementation is already good)
    ├── BallisticProjectile (physics-based arc)
    ├── HomingProjectile (AI-driven tracking)
    └── BeamProjectile (raycast-based)

EffectEntity (short-lived visuals)
├── DamageNumber (existing)
├── Particle (pooled particle systems)
└── AreaIndicator (visual feedback zones)
```

### Example Object Definitions

#### Rolling Coin (Moving + Interactable)
```gdscript
extends GameObject
class_name RollingCoin

func _init():
    physics_mode = PhysicsMode.DYNAMIC  # Physics-driven
    collision_mode = CollisionMode.SENSOR  # Detects overlap
    movement_mode = MovementMode.PHYSICS  # Rolls with inertia
    interaction_type = InteractionType.COLLECTIBLE  # Auto-collect
    render_tier = RenderTier.IMPORTANT  # Always render
```

#### Background Cloud (Moving + Transparent)
```gdscript
extends GameObject
class_name BackgroundCloud

func _init():
    physics_mode = PhysicsMode.NONE  # No physics
    collision_mode = CollisionMode.NONE  # No collision
    movement_mode = MovementMode.PATH  # Follows path
    interaction_type = InteractionType.NONE  # No interaction
    render_tier = RenderTier.DECORATIVE  # Can skip if slow
```

#### Stationary NPC (Static + Interactable)
```gdscript
extends GameObject
class_name ShopNPC

func _init():
    physics_mode = PhysicsMode.STATIC  # Doesn't move
    collision_mode = CollisionMode.MIXED  # Blocks + interaction zone
    movement_mode = MovementMode.STATIC  # No movement
    interaction_type = InteractionType.CONVERSABLE  # Opens shop UI
    render_tier = RenderTier.IMPORTANT  # Important NPC
```

#### Tree Obstacle (Static + Physical)
```gdscript
extends GameObject
class_name TreeObstacle

func _init():
    physics_mode = PhysicsMode.STATIC  # Doesn't move
    collision_mode = CollisionMode.PHYSICAL  # Blocks movement
    movement_mode = MovementMode.STATIC  # No movement
    interaction_type = InteractionType.NONE  # No interaction
    render_tier = RenderTier.IMPORTANT  # Blocks gameplay
```

## Performance Optimizations

### 1. Object Pooling System

Instead of `queue_free()` → `instantiate()` cycle (expensive):

```gdscript
class_name ObjectPool

var _pools: Dictionary = {}  # scene_path -> Array[Node]
var _active: Dictionary = {}  # instance_id -> Node

func get_or_create(scene_path: String) -> GameObject:
    if not _pools.has(scene_path):
        _pools[scene_path] = []

    var pool = _pools[scene_path]
    if pool.is_empty():
        var scene = load(scene_path)
        var instance = scene.instantiate()
        return instance

    var instance = pool.pop_back()
    instance.activate()
    _active[instance.get_instance_id()] = instance
    return instance

func return_to_pool(instance: GameObject) -> void:
    instance.deactivate()
    instance.reset()
    _active.erase(instance.get_instance_id())

    var scene_path = instance.get_scene_file_path()
    if not _pools.has(scene_path):
        _pools[scene_path] = []
    _pools[scene_path].append(instance)
```

**Performance gain**: 10-50x faster spawning, zero GC pressure for pooled objects

### 2. Collision Layer Strategy

Use Godot's 32 collision layers efficiently:

```
Layer 1:  Player body
Layer 2:  Enemy bodies
Layer 3:  Projectiles (player)
Layer 4:  Projectiles (enemy)
Layer 5:  Obstacles (physical)
Layer 6:  Collectibles (sensor)
Layer 7:  Triggers (sensor)
Layer 8:  Interaction zones
Layers 9-16: Reserved for future
Layers 17-32: Decorative/debug
```

Masks determine what each layer collides with:
- Player body: Enemies, Obstacles, Enemy projectiles, Collectibles, Triggers
- Enemy body: Player, Obstacles, Player projectiles
- Player projectile: Enemies only
- Collectible: Player only

**Performance gain**: Physics engine only checks relevant pairs

### 3. Render Tiers & LOD

```gdscript
class_name RenderManager

const FPS_THRESHOLD_LOW = 45
const FPS_THRESHOLD_CRITICAL = 30

var _current_tier: RenderTier = RenderTier.DECORATIVE

func _process(delta):
    var fps = Engine.get_frames_per_second()

    if fps < FPS_THRESHOLD_CRITICAL:
        _current_tier = RenderTier.CRITICAL
        _hide_decorative()
        _simplify_effects()
    elif fps < FPS_THRESHOLD_LOW:
        _current_tier = RenderTier.IMPORTANT
        _hide_decorative()
    else:
        _current_tier = RenderTier.DECORATIVE

func should_render(obj: GameObject) -> bool:
    return obj.render_tier <= _current_tier
```

**Performance gain**: Graceful degradation, maintain 60 FPS

### 4. Spatial Partitioning for Queries

Instead of `get_tree().get_nodes_in_group("enemies")`:

```gdscript
class_name SpatialGrid

var _cell_size: int = 128
var _grid: Dictionary = {}  # Vector2i -> Array[GameObject]

func insert(obj: GameObject) -> void:
    var cell = _world_to_cell(obj.global_position)
    if not _grid.has(cell):
        _grid[cell] = []
    _grid[cell].append(obj)

func query_radius(position: Vector2, radius: float) -> Array[GameObject]:
    var results = []
    var min_cell = _world_to_cell(position - Vector2.ONE * radius)
    var max_cell = _world_to_cell(position + Vector2.ONE * radius)

    for x in range(min_cell.x, max_cell.x + 1):
        for y in range(min_cell.y, max_cell.y + 1):
            var cell = Vector2i(x, y)
            if _grid.has(cell):
                for obj in _grid[cell]:
                    if obj.global_position.distance_squared_to(position) <= radius * radius:
                        results.append(obj)
    return results
```

**Performance gain**: O(log n) queries vs O(n) group iteration

## Migration Strategy

### Phase 1: Add New Base Class (Non-Breaking)
- Create `GameObject` with property-based system
- Keep existing classes working
- Add pooling infrastructure
- **No game code changes required**

### Phase 2: Migrate Leaf Classes
- Convert `Hero`, `Enemy` to use `GameObject`
- Update factories to set properties
- Test thoroughly
- **Existing scenes still work**

### Phase 3: Migrate Intermediate Classes
- Replace `Character`, `Collectible`, etc.
- Update scene files
- Remove old base classes

### Phase 4: Optimize & Extend
- Enable pooling for enemies/projectiles
- Implement spatial partitioning
- Add render tier management
- Measure performance gains

## Expected Performance Improvements

| Metric | Current | Target | Method |
|--------|---------|--------|--------|
| Enemy spawn time | ~0.5ms | ~0.05ms | Pooling |
| Entity count @ 60 FPS | ~80 | ~300 | Render tiers + pooling |
| Memory allocations/sec | ~1000 | ~50 | Pooling |
| Collision checks/frame | O(n²) | O(n log n) | Spatial grid |
| Physics load | 100% | 40% | Selective physics mode |

## Testing Requirements

- [ ] All existing tests pass with new hierarchy
- [ ] Performance benchmarks show improvement
- [ ] No visual regressions
- [ ] Memory profiling confirms reduced allocations
- [ ] AI agent can still play the game

## Open Questions

1. **Should we support runtime property changes?** (e.g., enemy becomes physical when killed and drops loot)
2. **How deep should component support go?** (full ECS or lightweight?)
3. **Should pooling be automatic or explicit?** (performance vs control)
4. **How to handle editor workflow?** (property dropdowns vs code)

## Next Steps

1. **Prototype `GameObject` base class** with property system
2. **Implement object pooling** for projectiles (easiest to test)
3. **Migrate one leaf class** (e.g., `Enemy`) as proof of concept
4. **Benchmark performance** difference
5. **Iterate based on results**

---

**Author**: Claude + Yves
**Date**: 2025-11-08
**Status**: Design proposal - awaiting review
