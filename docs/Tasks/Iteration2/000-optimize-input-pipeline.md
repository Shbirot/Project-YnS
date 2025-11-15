# 000 - Optimize Input Pipeline

## Goal  
Reduce input processing cost and unify all movement input logic under a single `InputDriver` class.

## Why  
Hero currently duplicates logic for action strengths, override logic, vector normalization. It adds unnecessary per-frame overhead.

## Implementation Steps  
1. Create `InputDriver.gd` with methods:
   - `get_direction()`
   - `set_override(vec)`
   - `clear_override()`
2. Move all `_read_movement_input()` logic into InputDriver.
3. Hero now calls:
   ```
   var dir = InputDriver.get_direction()
   ```
4. Cache action strengths per frame to avoid repeated calls.

## Performance Notes  
- Reduces redundant calls to `Input.get_action_strength`.
- No repeated vector normalization.

## DebugUtils  
- Use:
  ```
  DebugUtils.trace("Input vector", {"dir": dir})
  ```
  Only when `NF_DEBUG_INPUT=1`.

## Tests  
- Keyboard input works.
- Override input works.
- Input still works in simulation mode.
