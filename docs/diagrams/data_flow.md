# Data Flow

This diagram illustrates how data flows between the core managers and systems.

```
+---------------------+      +-----------------------+      +---------------------+
|   Input Sources     |----->|    HeroCharacter      |<---->|  AttributesManager  |
| (Keyboard, Touch)   |      | (hero_character.gd)   |      | (attributes_manager.gd)|
+---------------------+      +-----------------------+      +---------------------+
                                     |
                                     | _fire_projectile()
                                     v
+---------------------+      +-----------------------+      +---------------------+
|  TargetFinderUtil   |<---->|     CombatSystem      |      |   DamageSystem      |
| (target_finder_util.gd)|      |   (combat_system.gd)  |      |  (damage_system.gd)   |
+---------------------+      +-----------------------+      +---------------------+
                                     ^
                                     | apply_damage()
                                     |
+---------------------+      +-----------------------+      +---------------------+
|       Enemy         |----->|   MonsterCharacter    |<---->|  CalculationManager |
|     (enemy.gd)      |      | (monster_character.gd)|      | (calculation_manager.gd)|
+---------------------+      +-----------------------+      +---------------------+
```
