# Logging Guidelines

- Autoload `Logger` centralizes structured output with four levels: `DEBUG`, `INFO`, `WARN`, `ERROR`.
- `GameConfig` sets `NF_LOG_LEVEL` (default `INFO`); override in `.devenv` to filter noise (`DEBUG` in dev, `WARN`/`ERROR` in prod).
- Use helpers instead of raw `print`:
  - `Logger.debug("Wave spawned", {"wave": idx})`
  - `Logger.info("Enemy died", {"id": enemy_id})`
  - `Logger.warn("Missing archetype", {"id": archetype_id})`
  - `Logger.error("Checksum mismatch", ctx)`
- Hot paths should guard expensive log payloads: `if Logger.is_enabled_for(Logger.Level.DEBUG): Logger.debug(...)`.
- Tests can hook `Logger.set_test_listener` to capture emitted messages and verify filtering behaviour.
