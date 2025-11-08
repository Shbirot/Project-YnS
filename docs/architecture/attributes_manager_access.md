# AttributesManager Access Patterns

## Overview

The AttributesManager is a centralized store for player/hero attributes (hp, fire_rate, projectile_speed, crit_rate, etc.). This document describes the architectural pattern for accessing and modifying attributes.

## Architecture Principles

### 1. Single Owner: GameController

**GameController owns and initializes AttributesManager**

```gdscript
# In GameController.initialize()
_attributes_manager = AttributesManager.new()
add_child(_attributes_manager)
```

**Why:**
- Ensures AttributesManager exists before gameplay objects need it
- Single point of initialization and lifecycle management
- Autoload initialization order guarantees availability

### 2. Encapsulated Access: Through GameController API

**All access goes through GameController's public API, not directly to AttributesManager**

```gdscript
# GameController provides the API
func set_attribute(key: String, value) -> void
func get_attribute(key: String, default = null)
func get_all_attributes() -> Dictionary
func update_hero_attributes(stats: Dictionary) -> void
```

**Why:**
- **Encapsulation:** AttributesManager is an implementation detail
- **Single source of truth:** GameController controls all access
- **Easier refactoring:** Can change AttributesManager implementation without affecting callers
- **Testability:** Can mock GameController in tests
- **Future-proofing:** Can add validation, logging, events at the access point

### 3. Unidirectional Data Flow

```
Game Objects (Hero, Collectibles, etc.)
         ↓
   GameController.update_hero_attributes()
         ↓
   AttributesManager (internal)
         ↑
   GameController.get_attribute()
         ↑
  Systems (DamageSystem, UI, etc.)
```

**Write Path:** Game objects → GameController → AttributesManager
**Read Path:** Systems → GameController → AttributesManager

## Implementation Examples

### ✅ CORRECT: Characters Report Stats

```gdscript
# In HeroCharacter._ready()
func _report_stats_to_game_controller() -> void:
    if _game_controller == null:
        Log.warn("HeroCharacter: GameController not available")
        return
    # Report through API
    _game_controller.update_hero_attributes({
        "hp": max_health,
        "fire_rate": fire_interval,
        "projectile_speed": projectile_speed,
    })
```

**Why this is correct:**
- HeroCharacter doesn't know about AttributesManager
- Goes through GameController's API
- Single call after all initialization completes

### ✅ CORRECT: Systems Read Through API

```gdscript
# In DamageSystem._calculate_final_damage()
var controller = Engine.get_main_loop().root.get_node_or_null("GameController")
if controller:
    # Access through GameController API
    crit_rate = controller.get_attribute("crit_rate", 0.05)
    crit_multiplier = controller.get_attribute("crit_multiplier", 1.35)
```

**Why this is correct:**
- DamageSystem doesn't get AttributesManager directly
- Uses GameController.get_attribute() with defaults
- Encapsulation maintained

### ✅ CORRECT: UI Displays All Attributes

```gdscript
# In AttributeWindow._refresh()
var controller = _get_controller()
if controller:
    # Get all attributes through API
    var attrs: Dictionary = controller.get_all_attributes()
    for key in attrs.keys():
        _list.add_item("%s: %s" % [key, attrs[key]])
```

**Why this is correct:**
- UI doesn't access AttributesManager
- Uses GameController.get_all_attributes()
- Clean separation of concerns

### ❌ INCORRECT: Direct Manager Access

```gdscript
# DON'T DO THIS
var manager = GameController.get_attributes_manager()
manager.set_attribute("hp", 100)  # ❌ Breaks encapsulation
```

**Why this is wrong:**
- Exposes AttributesManager as public API
- Tight coupling to implementation
- Can't add validation or events
- Harder to refactor later

### ❌ INCORRECT: Multiple Syncs

```gdscript
# DON'T DO THIS
func set_fire_interval(value: float):
    fire_interval = value
    _sync_all_attributes()  # ❌ Syncing all attributes from a single setter

func set_projectile_speed(value: float):
    projectile_speed = value
    _sync_all_attributes()  # ❌ Redundant syncs
```

**Why this is wrong:**
- Wasteful - syncs all attributes when only one changed
- Can cause duplicate attribute sets
- Excessive logging and overhead

## Best Practices

### 1. Report Once After Initialization

**DO:** Report all stats in a single call after all initialization completes

```gdscript
func _ready() -> void:
    super._ready()
    # ... all initialization here ...
    _report_stats_to_game_controller()  # Once at the end
```

**DON'T:** Sync from multiple places or from setters

```gdscript
func _ready() -> void:
    super._ready()
    _sync()  # ❌
    setup_weapon()
    _sync()  # ❌ Multiple syncs
```

### 2. Use API Methods, Not get_attributes_manager()

**DO:** Use GameController's public API

```gdscript
var hp = GameController.get_attribute("hp", 100)
GameController.set_attribute("crit_rate", 0.15)
```

**DON'T:** Get the manager directly

```gdscript
var manager = GameController.get_attributes_manager()  # ❌
var hp = manager.get_attribute("hp")  # ❌
```

### 3. Provide Defaults When Reading

**DO:** Always provide sensible defaults

```gdscript
var crit_rate = controller.get_attribute("crit_rate", 0.05)
var crit_mult = controller.get_attribute("crit_multiplier", 1.35)
```

**DON'T:** Assume attributes exist

```gdscript
var crit_rate = controller.get_attribute("crit_rate")  # ❌ Might be null
```

### 4. Update Multiple Attributes Together

**DO:** Use update_hero_attributes() for multiple values

```gdscript
controller.update_hero_attributes({
    "hp": 100,
    "fire_rate": 0.6,
    "move_speed": 300,
})
```

**DON'T:** Make multiple individual calls

```gdscript
controller.set_attribute("hp", 100)  # ❌ Inefficient
controller.set_attribute("fire_rate", 0.6)
controller.set_attribute("move_speed", 300)
```

## Future Improvements

### Potential Enhancements

1. **Event System:** GameController could emit signals when attributes change
   ```gdscript
   signal attribute_changed(key: String, old_value, new_value)
   ```

2. **Validation:** GameController could validate attribute values
   ```gdscript
   func set_attribute(key: String, value) -> void:
       if key == "hp" and value < 0:
           Log.warn("Invalid hp value: %s" % value)
           return
       _attributes_manager.set_attribute(key, value)
   ```

3. **Persistence Hook:** GameController could auto-save on attribute changes
   ```gdscript
   func set_attribute(key: String, value) -> void:
       _attributes_manager.set_attribute(key, value)
       _persistence_manager.mark_dirty("attributes")
   ```

4. **Attribute Modifiers:** Support temporary buffs/debuffs
   ```gdscript
   func add_attribute_modifier(key: String, modifier: float, duration: float)
   ```

## API Reference

### GameController Attributes API

#### `set_attribute(key: String, value) -> void`
Sets a single attribute value.

**Example:**
```gdscript
GameController.set_attribute("crit_rate", 0.15)
```

#### `get_attribute(key: String, default = null)`
Gets a single attribute value with optional default.

**Example:**
```gdscript
var hp = GameController.get_attribute("hp", 100)
```

#### `get_all_attributes() -> Dictionary`
Returns all attributes as a dictionary.

**Example:**
```gdscript
var attrs = GameController.get_all_attributes()
for key in attrs:
    print("%s = %s" % [key, attrs[key]])
```

#### `update_hero_attributes(stats: Dictionary) -> void`
Updates multiple attributes at once.

**Example:**
```gdscript
GameController.update_hero_attributes({
    "hp": max_health,
    "fire_rate": fire_interval,
    "projectile_speed": projectile_speed,
})
```

---

**Last Updated:** 2025-11-09
**Status:** Implemented and tested
