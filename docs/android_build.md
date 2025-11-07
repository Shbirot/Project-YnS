# Android build & deployment

## Prerequisites
1. **Godot 4.2+** (standard build). Install from https://godotengine.org/download.
2. **Android SDK + NDK**: Run `./scripts/install_android_sdk.sh` (Linux) or install via Android Studio/command-line tools manually. Required components:
   - Android SDK Platform 34
   - Build-tools 34.x
   - NDK 25+ (Godot 4 requirement)
3. **Java 17+** (install OpenJDK 17/21, set `JAVA_HOME`; required by latest cmdline-tools).
4. **Godot Android export templates**: Install via *Editor → Project → Install Android Build Template*.
5. **USB debugging** enabled on the test device + `adb` on your workstation.

## Local signing setup

```
keytool -genkeypair -keystore config/keystore/nightfall.keystore \
  -alias nightfall -keyalg RSA -keysize 2048 -validity 3650
```

Update `game/export_presets.cfg` → `preset.2` with the actual keystore path, alias, and passwords (never commit secrets).

## Export commands

| Profile | Command | Output |
|---------|---------|--------|
| Dev desktop | `scripts/run_dev.sh desktop` | Runs the game with `env.dev`; add `REMOTE_DEBUG=1` to auto-connect to the editor debugger |
| Dev device | `scripts/run_dev.sh android` | Exports/install dev APK and prepares remote debugging |
| Stage APK | `scripts/export_android.sh stage` | `dist/android/stage/nightfall-stage.apk` |
| Prod AAB | `scripts/export_android.sh prod` | `dist/android/prod/nightfall-prod.aab` |

`scripts/run_dev.sh android` assumes `adb` sees one connected device/emulator. It reverses `tcp:6010` so the Godot remote debugger (Project Settings → Debug → Remote host `127.0.0.1`, port `6010`) can attach after you open the editor and the device build connects.

`scripts/install_android_sdk.sh` defaults to `tools/android-sdk/` inside the repo; export `ANDROID_HOME`/`ANDROID_NDK_ROOT` to that folder and add `$ANDROID_HOME/platform-tools` plus `$ANDROID_HOME/cmdline-tools/latest/bin` to your `PATH` once it completes.

`scripts/export_android.sh` wraps the Godot CLI: it sets `NIGHTFALL_ENV`, selects the preset, and mirrors exports inside `dist/` for easy CI artifacts.

## Installing on a device

```
adb devices      # ensure the phone is listed
adb install -r dist/android/stage/nightfall-stage.apk
```

For AAB uploads, use the Google Play Console → *Internal testing* or *Production* track.
