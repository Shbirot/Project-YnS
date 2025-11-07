#!/usr/bin/env bash
set -euo pipefail
PROFILE=${1:-dev}
PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
GODOT_BIN=${GODOT_BIN:-"$PROJECT_ROOT/tools/godot/godot4"}
GAME_PATH="$PROJECT_ROOT/game"

case "$PROFILE" in
  dev)
    PRESET="Android Dev"
    CMD="--export-debug"
    ;;
  stage)
    PRESET="Android Stage"
    CMD="--export-release"
    ;;
  prod)
    PRESET="Android Prod"
    CMD="--export-release"
    ;;
  *)
    echo "Unknown profile: $PROFILE" >&2
    exit 1
    ;;
esac

export NIGHTFALL_ENV=$PROFILE
"$GODOT_BIN" --headless --path "$GAME_PATH" $CMD "$PRESET"
