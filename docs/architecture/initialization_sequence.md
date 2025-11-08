# Initialization Sequence

## Overview

Nightfall Survivor uses a carefully ordered initialization sequence to ensure all managers and systems are available before gameplay objects need them.

## The Problem (Before Fix)

Previously, the initialization order had a race condition:

```
1. Godot auto-loads main.tscn (from project.godot)
2. Player scene instantiates → Player._ready() calls
3. Player tries to access AttributesManager → ❌ NOT YET CREATED
4. Warning: "attributes manager not set for Hero"
5. BootLoader._ready() defers _bootstrap()
6. GameController.initialize() creates AttributesManager (TOO LATE)
```

## The Solution

Have **GameController initialize itself** in `_ready()` before the main scene's children instantiate. Since autoloads load before the main scene, this guarantees AttributesManager exists when needed.

## Current Initialization Order

### Phase 1: Autoloads (In Order)

```
1. Logger._ready()                  → Logging system ready
2. ConfigManager._ready()           → Config system ready
3. GameConfig._ready()              → Environment profiles ready
4. PersistenceManager._ready()      → Save/load system ready
5. GameController._ready()          → ✅ CREATES AttributesManager, DamageManager, ApiManager
6. BootLoader._ready()              → Schedules main scene loading
7. ObjectCatalog._ready()           → Factory system ready
8. SteamManager._ready()            → Steam integration ready (if enabled)
```

### Phase 2: Main Scene Auto-Loads

```
main.tscn (from project.godot run/main_scene) instantiates:
  → Player._ready()                 → ✅ AttributesManager is available
  → Enemy spawner._ready()
  → HUD._ready()
  → etc.
```

### Phase 3: Deferred Bootstrap (Optional)

```
BootLoader._bootstrap() (next frame):
  → GameController.initialize()     → Idempotent, already initialized
  → (Future post-init logic can go here)
```

## Key Design Decisions

### 1. GameController Initializes in `_ready()`

**Why:** Ensures AttributesManager exists before any game scenes load.

**Implementation:**
```gdscript
func _ready() -> void:
    # Initialize immediately when GameController loads (before main scene)
    # This ensures AttributesManager is available for any characters that load
    initialize()

func initialize() -> void:
    if _initialized:
        return  # Idempotent
    # Create managers...
```

### 2. Main Scene in project.godot

**Why:** Standard Godot approach - main scene is defined in project settings.

**How it works:** Godot automatically loads main.tscn after all autoloads finish their `_ready()` calls.

### 3. BootLoader is Optional

**Why:** With GameController self-initializing, BootLoader is now just a hook for post-init logic.

**Current purpose:** Provides a place for future initialization steps that need to run after the main scene loads.

**Flow:**
```gdscript
func _ready() -> void:
    call_deferred("_bootstrap")  # Run after main scene loads

func _bootstrap() -> void:
    controller.initialize()      # Idempotent - already done
    # Future: Add post-main-scene initialization here
```

## Manager Availability Table

| Manager | Available From | Created By | Type |
|---------|---------------|------------|------|
| **Logger** | Logger._ready() | Autoload | Autoload |
| **ConfigManager** | ConfigManager._ready() | Autoload | Autoload |
| **GameConfig** | GameConfig._ready() | Autoload | Autoload |
| **PersistenceManager** | PersistenceManager._ready() | Autoload | Autoload |
| **AttributesManager** | GameController._ready() | GameController | Child Node |
| **DamageNumberManager** | GameController._ready() | GameController | Child Node |
| **ApiManager** | GameController._ready() | GameController | Child Node |
| **ObjectCatalog** | ObjectCatalog._ready() | Autoload | Autoload |
| **SteamManager** | SteamManager._ready() | Autoload | Autoload |

## Testing Considerations

### Unit Tests

The logic test runner manually creates autoloads and calls `initialize()`:

```gdscript
AUTOLOAD_SPECS := [
    {"name": "GameController", "path": "...", "initialize": true},
]

# After creating autoload:
if spec.get("initialize", false):
    instance.initialize()
```

This works because `initialize()` is **idempotent** - calling it multiple times is safe.

### Environment Variables

- `NIGHTFALL_DISABLE_BOOT=1` - Skip BootLoader sequence (for testing)
- `DISABLE_API_MANAGER=1` - Don't start API server (for testing)

## Expected Log Output (Dev)

**Before fix:**
```
[INFO] Logger initialized
[INFO] ConfigManager initialized for env=dev
[WARN] HeroCharacter: attributes manager not set for Hero  ← ❌ BAD
[DEBUG] HeroCharacter Hero damage_type=magic_arcane
...
[INFO] AttributesManager reset (5 attributes)  ← TOO LATE
```

**After fix:**
```
[INFO] Logger initialized
[INFO] ConfigManager initialized for env=dev
[INFO] AttributesManager reset (5 attributes)  ← ✅ EARLY
...
[DEBUG] HeroCharacter Hero damage_type=magic_arcane  ← ✅ NO WARNING
[INFO] HeroCharacter ready: Hero
```

## Common Pitfalls

### ❌ Adding Heavy Logic to Autoload `_ready()`

**Problem:** Autoloads run sequentially. Heavy processing blocks the next autoload.

**Solution:** Use `call_deferred()` or move heavy work to `initialize()`.

### ❌ Accessing Managers in Global Scope

**Problem:**
```gdscript
# This runs at parse time, before autoloads exist!
var attributes = GameController._attributes_manager  # NULL!
```

**Solution:** Access in `_ready()` or later:
```gdscript
func _ready():
    var attributes = GameController._attributes_manager  # ✓ Available
```

### ❌ Depending on Initialization Order Between Autoloads

**Problem:** Autoload A calls methods on Autoload B in `_ready()`, but B hasn't initialized yet.

**Solution:** Use `call_deferred()` or check if the other autoload is ready.

## Future Improvements

1. **Make AttributesManager an Autoload**: Would simplify access pattern (no need for GameController)
2. **Add initialization progress callbacks**: For splash screen/loading bar
3. **Lazy initialization**: Only create managers when first accessed
4. **Dependency injection**: Pass managers to objects instead of global access

---

**Last Updated**: 2025-11-09
**Status**: Implemented and tested
