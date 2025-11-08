# Block Diagram

```
BootLoader
   │
   └── GameController
        ├── Logger (autoload)
        ├── ConfigManager (autoload)
        ├── PersistenceManager (autoload)
        ├── ApiManager (port 6969)
        └── Menu Layer (placeholder)
                │
                └── Main Scene (main.tscn)
                      ├── World
                      │    ├── Player (HeroCharacter)
                      │    │     ├── Weapon (Resource)
                      │    │     └── Projectile scenes / Ammunition
                      │    ├── EnemySpawner
                      │    └── Obstacles / Collectibles
                      └── HUD
```
