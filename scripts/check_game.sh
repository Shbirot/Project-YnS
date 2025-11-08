#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
GODOT_BIN=${GODOT_BIN:-"$PROJECT_ROOT/tools/godot/godot4"}
GAME_PATH="$PROJECT_ROOT/game"

run_gdlint() {
	if [[ "${SKIP_GDLINT:-0}" == "1" ]]; then
		echo "[check] SKIP_GDLINT=1, skipping gdlint."
		return
	elif ! command -v gdlint >/dev/null 2>&1; then
		echo "[check] gdlint not found; skipping GDScript lint. Install via 'pip install gdtoolkit'." >&2
		return
	fi
	echo "[check] Running gdlint..."
	gdlint "$GAME_PATH" || {
		echo "[check] gdlint reported issues." >&2
		exit 1
	}
}

run_godot_check() {
	local runner=()
	if command -v xvfb-run >/dev/null 2>&1; then
		runner=(xvfb-run --auto-servernum --server-args='-screen 0 1280x720x24')
	else
		echo "[check] WARNING: xvfb-run not found; attempting headless Godot run without a virtual display." >&2
	fi
	mkdir -p "$HOME/.local/share/godot/app_userdata/Nightfall Survivor/logs"
	echo "[check] Running Godot --check-only..."
	"${runner[@]}" "$GODOT_BIN" --headless --path "$GAME_PATH" --check-only
}

run_gdlint
run_godot_check
echo "[check] All checks completed."
