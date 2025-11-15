# 008 - Input Driver Overrides

## Goal  
Clean separation between override input and keyboard input.

## Why  
Override previously caused hero movement freeze.

## Steps  
1. Implement `InputDriver.override_active`.
2. Hero uses:
   ```
   var dir = InputDriver.get_direction()
   ```
3. Override only applied when non-zero.

## Performance Notes  
- Smaller hero logic.
- Fewer branches per physics frame.

## DebugUtils  
- Log when override toggles.

## Tests  
- Override ON works.
- Override OFF fallback works.
