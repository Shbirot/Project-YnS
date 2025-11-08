# Object Creation Flow

This diagram shows the process of creating a game object from a JSON definition.

```
+--------------------------+
| catalog.json             |
| (Defines object specs)   |
+--------------------------+
           |
           | 1. Loaded by
           v
+--------------------------+
| ObjectCatalog (autoload) |
| (object_catalog.gd)      |
+--------------------------+
           |
           | 2. create_hero("player")
           v
+--------------------------+
| HeroFactory              |
| (hero_factory.gd)        |
+--------------------------+
           |
           | 3. Instantiates scene
           |    and applies properties
           v
+--------------------------+
| player.tscn              |
| (Instantiated in-game)   |
+--------------------------+
```
