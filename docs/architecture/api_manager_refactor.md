# APIManager Refactor - Global Facade Pattern

## Overview

APIManager is being refactored from a simple TCP server into a **Global Facade/Gateway** that provides a unified API for all game systems.

## Architecture

### **Before (Old):**
```
Character → GameController → AttributesManager
DamageSystem → Character.apply_damage()
UI → player.health_changed signal
```

**Problems:**
- Scattered responsibilities
- Hero manages its own HP
- GameController is just a passthrough
- Multiple signal sources
- Tight coupling

### **After (New):**
```
┌────────────────────────────────────────────────┐
│         APIManager (Autoload Singleton)        │
│  • Global game API facade                     │
│  • Holds all manager references               │
│  • Emits all game signals                     │
│  • Single source of truth                     │
└────────────────────────────────────────────────┘
        ↓ owns
┌──────────────────┐  ┌──────────────────┐
│ AttributesManager│  │DamageNumberMgr   │
│ - hero HP        │  │- visual effects  │
│ - hero stats     │  │                  │
└──────────────────┘  └──────────────────┘
```

## New APIManager API

### **Hero HP Management**
```gdscript
# Damage and healing
APIManager.damage_hero(amount: int, source = null) -> void
APIManager.heal_hero(amount: int) -> void
APIManager.kill_hero(source = null) -> void

# HP queries
APIManager.get_hero_hp() -> int
APIManager.get_hero_max_hp() -> int
APIManager.set_hero_max_hp(value: int) -> void
```

### **Hero Attributes**
```gdscript
APIManager.set_hero_attribute(key: String, value) -> void
APIManager.get_hero_attribute(key: String, default = null)
APIManager.get_all_hero_attributes() -> Dictionary
```

### **Signals (Centralized)**
```gdscript
signal hero_hp_changed(current: int, max_hp: int)
signal hero_died(source)
signal hero_attribute_changed(key: String, value)
```

### **Visual Effects**
```gdscript
APIManager.show_damage_number(damage: float, type: String, is_crit: bool, position: Vector2)
```

## Usage Examples

### **Damage System**
```gdscript
# OLD
if target.has_method("apply_damage"):
    target.apply_damage(amount, source)

# NEW
if target.is_in_group("heroes"):
    APIManager.damage_hero(amount, source)
else:
    target.apply_damage(amount, source)  # Monsters keep local HP
```

### **Main Scene Setup**
```gdscript
# OLD
player.health_changed.connect(hud.update_health)
player.player_died.connect(_on_player_died)

# NEW
APIManager.hero_hp_changed.connect(hud.update_health)
APIManager.hero_died.connect(_on_player_died)
```

### **Hero Initialization**
```gdscript
# OLD
func _ready():
    _current_health = max_health
    health_changed.emit(_current_health, max_health)
    _report_stats_to_game_controller()

# NEW
func _ready():
    APIManager.set_hero_max_hp(max_health)
    APIManager.set_hero_attribute("fire_rate", fire_interval)
    # HP initialized automatically by APIManager
```

### **UI Queries**
```gdscript
# OLD
var hp = controller.get_attribute("hp", 100)

# NEW
var hp = APIManager.get_hero_hp()
```

## Migration Steps

1. ✅ Design new APIManager API
2. ⬜ Add HP management to AttributesManager
3. ⬜ Refactor APIManager to facade pattern
4. ⬜ Update DamageSystem to route through APIManager
5. ⬜ Remove HP management from Hero/Character
6. ⬜ Update Main.gd signal connections
7. ⬜ Update all API callers
8. ⬜ Update tests
9. ⬜ Remove GameController passthrough methods

## Benefits

✅ **Single Source of Truth**: APIManager is the only entry point
✅ **Loose Coupling**: Components don't know about each other
✅ **Easy Testing**: Mock APIManager, test everything
✅ **Clear Responsibilities**: Each manager has one job
✅ **Centralized Signals**: One place to listen for game events
✅ **Type Safety**: Dedicated methods instead of string keys
✅ **Scalability**: Easy to add new managers/systems

## File Changes

### New Files:
- None (refactor existing)

### Modified Files:
- `scripts/core/api_manager.gd` - Add facade API
- `scripts/core/attributes_manager.gd` - Add HP management
- `scripts/systems/damage_system.gd` - Route through APIManager
- `scripts/characters/character.gd` - Remove HP from heroes
- `scripts/characters/hero_character.gd` - Simplify initialization
- `scripts/main.gd` - Connect to APIManager signals
- `autoload/autoload.cfg` - Ensure APIManager is autoloaded

---

**Status:** Design Complete - Ready for Implementation
**Date:** 2025-11-09
