# GDScript Style Checklist

- Prefer early returns to avoid deep nesting; bail out as soon as preconditions fail.
- Use `match` when branching on discrete states rather than long `if/elif` chains.
- Assign booleans directly (`is_alive = hp > 0`) instead of redundant `if/else`.
- Keep gameplay functions focused (< 40 LOC); extract helpers for repeated logic (spawn positions, config loads, movement math).
- Route debug output through `DebugUtils.debug_log` + `Logger` so `strip_debug.py` can remove dev-only tracing.
- Access shared systems via `SingletonUtil` and Resource-driven data rather than hardcoded scenes/values.
