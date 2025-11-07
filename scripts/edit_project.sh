#!/usr/bin/env bash
set -euo pipefail
PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
GODOT_BIN=${GODOT_BIN:-"$PROJECT_ROOT/tools/godot/godot4"}
exec "$GODOT_BIN" --editor --path "$PROJECT_ROOT/game"
