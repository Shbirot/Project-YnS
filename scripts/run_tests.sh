#!/usr/bin/env bash
set -euo pipefail

CODEX_MODE=0
VERBOSE_MODE=0
ROBOT_ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --codex)
      CODEX_MODE=1
      ;;
    --verbose)
      VERBOSE_MODE=1
      ;;
    *)
      ROBOT_ARGS+=("$1")
      ;;
  esac
  shift
done

export PATH="$HOME/.local/bin:$PATH"
export PYTHONPATH="$PWD"
export GODOT_BIN="${GODOT_BIN:-$PWD/tools/godot/godot4}"
export PYTHONDONTWRITEBYTECODE=1

if [[ $CODEX_MODE -eq 1 ]]; then
  export SKIP_UI_TESTS=1
fi

if [[ $VERBOSE_MODE -eq 1 ]]; then
  export LOGIC_TEST_VERBOSE=1
fi

echo "[run_tests] Running Robot Framework suites..."
robot "${ROBOT_ARGS[@]}" tests/robot/
