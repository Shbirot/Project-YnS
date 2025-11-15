# Release Build Flow

1. Run `python scripts/devtool.py` and choose option `10` (`Build prod export`).
2. The devtool copies `game/` into `build/stripped_game/`, runs `scripts/strip_debug.py` to remove `# DEBUG-ONLY` blocks and `DebugUtils.debug_log` calls, then exports the `Desktop Prod` preset via Godot.
3. Final binaries land under `build/prod/nightfall.x86_64`; logs print the source/destination so CI can upload artifacts.
4. Ensure `NF_LOG_LEVEL` is set to `WARN`/`ERROR` in `.devenv` or CI env before triggering prod builds so runtime logs stay quiet.

`scripts/strip_debug.py` accepts `--src` / `--dest` and can be run manually for ad-hoc stripping if needed.
