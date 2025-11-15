# PC Controls

| Action | Keys |
| --- | --- |
| Move Up | `W` / `Arrow Up` |
| Move Down | `S` / `Arrow Down` |
| Move Left | `A` / `Arrow Left` |
| Move Right | `D` / `Arrow Right` |
| Confirm / Start | `Enter` / `Space` (`ui_accept`) |
| Cancel / Pause | `Esc` (`ui_cancel`) |

- Movement uses both WASD and arrow keys via the `move_*` and `ui_*` actions, so controllers / keyboard overrides can plug in without re-binding.
- Menu navigation listens to the `ui_*` actions, matching Godot defaults; `InputDriver` scripts replay these actions for automation.
