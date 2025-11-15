# 003 - Preload Weapon System

## Goal  
Preload all weapons and ammo resources at boot.

## Why  
Runtime loading of `.tres` and scenes is expensive during gameplay.

## Steps  
1. Create `WeaponRegistry.gd` Singleton.
2. Preload:
   - all weapons in res://src/features/weapons/
   - all ammo scenes
3. Replace:
   ```
   load("weapon.tres")
   ```
   with:
   ```
   WeaponRegistry.get("weapon_id")
   ```

## Performance Notes  
- Eliminates runtime disk I/O.
- Ensures fast weapon spawning.

## DebugUtils  
- Log number of weapons preloaded.

## Tests  
- Weapon instantiation works.
- Ammo spawns correctly.
