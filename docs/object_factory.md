# Data-Driven Object Factory

Nightfall Survivor now relies entirely on native Godot tooling for data-driven entities—no external Python modules required. Everything lives in a single JSON file that the engine consumes directly.

## Authoring flow

1. Edit `game/config/data/objects/catalog.json`. Each top-level key (`hero`, `monster`, `projectile`, `weapon`, etc.) maps an object id to a dictionary describing its scene/resource paths, stats, properties, and optional metadata (icons, tags, etc.).

```json
{
  "hero": {
    "hero_arcane": {
      "scene": "res://scenes/player.tscn",
      "properties": {
        "move_speed": 320,
        "max_health": 140,
        "equipped_weapon": "res://resources/weapons/basic_wand.tres"
      },
      "metadata": {
        "icon": "res://assets/hero_pika.svg"
      }
    }
  }
}
```

2. That JSON is loaded at runtime by the `ObjectCatalog` autoload (`/root/ObjectCatalog`). There is no build step—simply save the file and run the game.

```gdscript
var hero = ObjectCatalog.create_hero("hero_arcane")
get_tree().current_scene.add_child(hero)
```

| Factory | Responsibility |
|---------|----------------|
| `BaseObjectFactory` | Instantiates scenes/resources and applies arbitrary property overrides. |
| `HeroFactory` | Extends the base class with weapon/resource coercion. |
| `MonsterFactory` | Placeholder for AI/loot hooks. |
| `ProjectileFactory` | Placeholder for projectile-specific tuning. |

Any changes you make to `catalog.json` are immediately reflected in-game: the startup menus (`StartMenuWindow` → `GameSetupWindow`) query `ObjectCatalog` to list heroes and weapons, so new entries automatically appear as selectable loadouts on boot.
