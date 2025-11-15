# 011 - Early Config Validation

## Goal  
Validate and checksum all config files at boot.

## Why  
Prevents runtime stalls when loading configs lazily.

## Steps  
1. `ConfigValidator.gd`:
   - scan config directory
   - validate fields
   - compute checksums
2. Store validated configs.

## Performance Notes  
- No mid-game config parsing.
- Faster spawner logic.

## DebugUtils  
- Log validation results.

## Tests  
- Missing/wrong configs rejected.
