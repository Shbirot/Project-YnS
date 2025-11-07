#!/usr/bin/env bash
set -euo pipefail
PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
GODOT_BIN=${GODOT_BIN:-"$PROJECT_ROOT/tools/godot/godot4"}
export NIGHTFALL_ENV=${NIGHTFALL_ENV:-dev}
exec "$GODOT_BIN" --path "$PROJECT_ROOT/game"
