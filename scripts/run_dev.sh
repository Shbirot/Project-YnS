#!/usr/bin/env bash
set -euo pipefail
PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
GODOT_BIN=${GODOT_BIN:-"$PROJECT_ROOT/tools/godot/godot4"}
GAME_PATH="$PROJECT_ROOT/game"
REMOTE_PORT=${REMOTE_PORT:-6010}
REMOTE_DEBUG=${REMOTE_DEBUG:-0}
RESET_PERSISTENCE=0
MODE="desktop"
POSITIONAL=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --fresh|--reset)
      RESET_PERSISTENCE=1
      shift
      ;;
    desktop|android)
      MODE="$1"
      shift
      break
      ;;
    *)
      break
      ;;
  esac
done

if [[ $# -gt 0 ]]; then
  MODE="$1"
  shift
fi

run_desktop() {
  export NIGHTFALL_ENV=dev
  if [[ "$RESET_PERSISTENCE" == "1" ]]; then
    local persist_path="$HOME/.local/share/godot/app_userdata/Nightfall Survivor/persistence.json"
    echo "[run_dev] removing persistence file: $persist_path"
    rm -f "$persist_path"
  fi
  local cmd=("$GODOT_BIN" --path "$GAME_PATH")
  if [[ "$REMOTE_DEBUG" == "1" ]]; then
    local endpoint="tcp://127.0.0.1:$REMOTE_PORT"
    echo "[run_dev] launching desktop build with remote debugger on $endpoint"
    echo "          Make sure the Godot editor is open with this project to accept the connection."
    cmd+=(--remote-debug "$endpoint")
  else
    echo "[run_dev] launching desktop build (remote debugger disabled; set REMOTE_DEBUG=1 to enable)."
  fi
  exec "${cmd[@]}" "$@"
}

ensure_adb() {
  if ! command -v adb >/dev/null 2>&1; then
    echo "[run_dev] adb is not installed or not on PATH. Install Android platform-tools first." >&2
    exit 1
  fi
}

run_android() {
  ensure_adb
  export NIGHTFALL_ENV=dev
  local preset="Android Dev"
  local apk_path="$PROJECT_ROOT/dist/android/dev/nightfall-dev.apk"
  echo "[run_dev] exporting $preset build..."
  "$GODOT_BIN" --headless --path "$GAME_PATH" --export-debug "$preset"
  echo "[run_dev] installing APK to connected device..."
  adb install -r "$apk_path"
  echo "[run_dev] enabling reverse port-forwarding for Godot remote debugger on tcp:$REMOTE_PORT"
  adb reverse "tcp:$REMOTE_PORT" "tcp:$REMOTE_PORT" || true
  echo "[run_dev] launching app (package com.nightfallsurvivor.dev)"
  adb shell monkey -p com.nightfallsurvivor.dev -c android.intent.category.LAUNCHER 1
  cat <<MSG

Device build is running. To attach the Godot debugger/inspector:
  1. Open the project in the Godot editor (./scripts/edit_project.sh).
  2. In Project Settings → Debug → Remote, ensure host is 127.0.0.1 and port $REMOTE_PORT (default).
  3. Use the Remote tab in the debugger once the device build connects (requires debug export).
MSG
}

case "$MODE" in
  desktop)
    run_desktop "$@"
    ;;
  android)
    run_android "$@"
    ;;
  *)
    cat <<USAGE >&2
Usage: ./scripts/run_dev.sh [options] <desktop|android>

Options:
  --fresh, --reset    Delete the local persistence file before launching (desktop only)

Examples:
  ./scripts/run_dev.sh desktop
  ./scripts/run_dev.sh --fresh desktop
  ./scripts/run_dev.sh android
USAGE
    exit 1
    ;;
esac
