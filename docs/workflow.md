# Development workflow

1. **Local development (dev profile)**
   - Launch the editor with `./scripts/edit_project.sh`.
   - Run the current build via `./scripts/run_dev.sh desktop`. Set `REMOTE_DEBUG=1` if you want the standalone build to connect back to the editor’s debugger (the editor must be open first).
   - Desktop exports/CI runs target the `Desktop Dev` preset which automatically injects the `env.dev` feature flag, so the same build is used on Linux/macOS/Windows.
2. **Device testing (stage profile)**
   - Use `scripts/install_android_sdk.sh` once to fetch SDK/NDK locally (or point to an existing install) and export `ANDROID_HOME` + `ANDROID_NDK_ROOT`.
   - Use `scripts/run_dev.sh android` for iterative dev installs (builds the dev preset, installs via `adb`, and configures remote debugging).
   - For stage parity builds, run `scripts/export_android.sh stage` and install them with `adb install -r dist/android/stage/nightfall-stage.apk`.
   - Stage builds keep analytics disabled but tighten spawn cadence, making balancing closer to production.
3. **Production candidates (prod profile)**
   - Configure a release keystore under `config/keystore/` and update `game/export_presets.cfg` with secure credentials.
   - Run `scripts/export_android.sh prod` to generate an `.aab` bundle for Play Console upload.

## Branching & environments

- `main` → prod releases; build from tags.
- `develop` → stage testing; automatically exported on every push.
- Feature branches → merge via PRs with CI running lint + desktop smoke tests.

## Testing strategy

- **Gameplay smoke**: `godot4 --headless --run-test` isn’t available yet, so we rely on deterministic integration scenes (add them under `game/tests/`).
- **Unit tests**: Use GUT or WAT if you want TDD for systems (project already structured so you can drop an addon under `game/addons/`).
- **CI**: `.github/workflows/ci.yml` runs lint (gdformat optional) and headless exports for dev/stage. Modify it once you plug into a signing service.
