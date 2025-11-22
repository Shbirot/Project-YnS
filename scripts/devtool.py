#!/usr/bin/env python3
"""Nightfall Devtool CLI."""
from __future__ import annotations

import os
import shutil
import subprocess
import sys
from pathlib import Path

LINUX = sys.platform.startswith("linux")
WINDOWS = sys.platform.startswith("win32") or sys.platform.startswith("cygwin")

REPO_ROOT = Path(__file__).resolve().parents[1]
GAME_DIR = REPO_ROOT / "game"
DEFAULT_GODOT = REPO_ROOT / "tools" / "godot" / ("godot4" + ".exe" if WINDOWS else "")
DEVENV_PATH = REPO_ROOT / ".devenv"


def _godot_binary() -> Path:
    godot = Path(os.environ.get("GODOT_BIN", DEFAULT_GODOT))
    if not godot.exists():
        print(f"[devtool] Godot binary not found at {godot}")
        sys.exit(1)
    return godot


def _run(cmd: list[str], env: dict[str, str] | None = None) -> None:
    merged_env = os.environ.copy()
    merged_env.update(_load_devenv())
    merged_env.setdefault("LC_ALL", "C.UTF-8")
    merged_env.setdefault("LANG", "C.UTF-8")
    if env:
        merged_env.update(env)
    subprocess.run(cmd, cwd=REPO_ROOT, check=True, env=merged_env)


def _load_devenv() -> dict[str, str]:
    if not DEVENV_PATH.exists():
        DEVENV_PATH.write_text("# DEV environment variables\nMANUAL_LAUNCHER_AUTO_EXIT=30\nDEBUG=1\nNF_LOG_LEVEL=DEBUG\nDEBUG_COOLDOWN_MS=5000\n", encoding="utf-8")
    env_vars: dict[str, str] = {}
    for line in DEVENV_PATH.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        env_vars[key.strip()] = value.strip()
    return env_vars


def edit_devenv() -> None:
    env_vars = _load_devenv()
    keys = list(env_vars.keys())
    while True:
        print("\nCurrent .devenv variables:")
        for idx, key in enumerate(keys, 1):
            print(f"  {idx}) {key}={env_vars[key]}")
        print("  a) Add new variable")
        print("  q) Save & return")
        choice = input("Select an entry to edit: ").strip().lower()
        if choice == "q":
            break
        if choice == "a":
            new_key = input("New variable name: ").strip()
            if new_key:
                new_value = input("Value: ").strip()
                env_vars[new_key] = new_value
                keys = list(env_vars.keys())
            continue
        if not choice.isdigit() or not (1 <= int(choice) <= len(keys)):
            print("Invalid selection.")
            continue
        key = keys[int(choice) - 1]
        new_value = input(f"Enter new value for {key} (current {env_vars[key]}): ").strip()
        if new_value:
            env_vars[key] = new_value
    with DEVENV_PATH.open("w", encoding="utf-8") as fh:
        fh.write("# DEV environment variables\n")
        for key in env_vars:
            fh.write(f"{key}={env_vars[key]}\n")


def launch_editor() -> None:
    cmd = [str(_godot_binary()), "--editor", "--path", str(GAME_DIR)]
    _run(cmd)


def run_manual_simulation() -> None:
    editor_smoke()
    env = {"MANUAL_LAUNCHER_AUTO_EXIT": "0"}
    cmd = [
        str(_godot_binary()),
        "--path",
        str(GAME_DIR),
        "--script",
        "res://tests/sim/manual_launcher.gd",
    ]
    _run(cmd, env=env)


def run_timed_simulation() -> None:
    editor_smoke()
    default_seconds = int(_load_devenv().get("MANUAL_LAUNCHER_AUTO_EXIT", "30"))
    seconds = input(f"Auto-exit after N seconds [default {default_seconds}]: ").strip()
    if not seconds:
        seconds = str(default_seconds)
    env = {"MANUAL_LAUNCHER_AUTO_EXIT": seconds}
    cmd = [
        str(_godot_binary()),
        "--path",
        str(GAME_DIR),
        "--script",
        "res://tests/sim/manual_launcher.gd",
    ]
    _run(cmd, env=env)


def run_autoplay() -> None:
    default_cfg = "res://tests/sim/autoplay/autoplay_basic.json"
    cfg = input(f"Autoplay config (res://...)? [{default_cfg}]: ").strip() or default_cfg
    cmd = [
        str(_godot_binary()),
        "--headless",
        "--path",
        str(GAME_DIR),
        "--script",
        "res://tests/sim/autoplay/autoplay_runner.gd",
        "--",
        "--config",
        cfg,
    ]
    _run(cmd)


def run_tests() -> None:
    _run(["bash", "scripts/run_tests.sh"])


def editor_smoke() -> None:
    cmd = [
        str(_godot_binary()),
        "--editor",
        "--headless",
        "--path",
        str(GAME_DIR),
        "--quit",
    ]
    config_dir = Path.home() / ".config" / "godot"
    config_dir.mkdir(parents=True, exist_ok=True)
    env = {
        "XDG_CONFIG_HOME": str(Path.home()),
    }
    process = subprocess.Popen(
        cmd,
        cwd=REPO_ROOT,
        env={**os.environ, "LC_ALL": "C.UTF-8", "LANG": "C.UTF-8"},
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    buffer: list[str] = []
    live_lines: list[str] = []
    try:
        poll_count = 0
        while True:
            if process.stdout is None:
                break
            line = process.stdout.readline()
            if line:
                line = line.rstrip()
                buffer.append(line)
                print(line)
            if process.poll() is not None:
                break
            poll_count += 1
            if poll_count >= 16:
                break
    finally:
        process.communicate()
    log_path = REPO_ROOT / "smoke.log"
    log_path.write_text("\n".join(buffer), encoding="utf-8")
    errors = [line for line in buffer if "ERROR" in line or "SCRIPT ERROR" in line]
    if errors:
        print("[devtool] Smoke test reported errors:")
        for line in errors[:10]:
            print("  " + line)
    else:
        print("[devtool] Smoke test completed without detected errors.")
    print("[devtool] Full output:\n" + "\n".join(buffer[-40:]))
    print(f"[devtool] Full log saved to {log_path}")


def deploy_placeholder() -> None:
    print("[devtool] Deploy flow is not implemented yet. Hook CI/build steps here when ready.")


def aseprite_placeholder() -> None:
    bin_hint = os.environ.get("ASEPRITE_BIN", "aseprite")
    print(
        "[devtool] Add ASEPRITE_BIN to your environment once you have a CLI build, "
        "then extend this handler to launch it automatically."
    )
    print(f"[devtool] Expected binary: {bin_hint}")


def build_prod() -> None:
    _run([sys.executable, "scripts/build_manifest.py"])
    stripped_project = REPO_ROOT / "build" / "stripped_game"
    if stripped_project.exists():
        shutil.rmtree(stripped_project)
    shutil.copytree(GAME_DIR, stripped_project)
    strip_cmd = [
        sys.executable,
        "scripts/strip_debug.py",
        "--src",
        str(GAME_DIR / "src"),
        "--dest",
        str(stripped_project / "src"),
    ]
    _run(strip_cmd)
    version_file = REPO_ROOT / ".VERSION"
    if version_file.exists():
        shutil.copy(version_file, stripped_project / ".VERSION")
    build_output = REPO_ROOT / "build" / "prod" / "nightfall.x86_64"
    build_output.parent.mkdir(parents=True, exist_ok=True)
    export_cmd = [
        str(_godot_binary()),
        "--headless",
        "--path",
        str(stripped_project),
        "--export-release",
        "Desktop Prod",
        str(build_output),
    ]
    _run(export_cmd)


def run_input_autoplay() -> None:
    editor_smoke()
    default_script = "res://tests/sim/autoplay/autoplay_input_basic.json"
    script_path = input(f"Input script (res://...)? [{default_script}]: ").strip() or default_script
    env = {"NF_INPUT_SCRIPT_PATH": script_path, "MANUAL_LAUNCHER_AUTO_EXIT": "0"}
    cmd = [
        str(_godot_binary()),
        "--headless",
        "--path",
        str(GAME_DIR),
        "--script",
        "res://tests/sim/manual_launcher.gd",
    ]
    _run(cmd, env=env)


MENU_OPTIONS = {
    "1": ("Launch Godot editor", launch_editor),
    "2": ("Run manual simulation (no auto-exit)", run_manual_simulation),
    "3": ("Run timed simulation", run_timed_simulation),
    "4": ("Run autoplay simulation", run_autoplay),
    "5": ("Run Robot tests", run_tests),
    "6": ("Editor smoke test (--headless --quit)", editor_smoke),
    "7": ("Deploy build (placeholder)", deploy_placeholder),
    "8": ("Open Aseprite (placeholder)", aseprite_placeholder),
    "9": ("Edit .devenv variables", edit_devenv),
    "10": ("Build prod export", build_prod),
    "11": ("Run input-script autoplay", run_input_autoplay),
    "q": ("Quit", None),
}


def main() -> None:
    while True:
        print("\nNightfall Devtool")
        for key, (label, _) in MENU_OPTIONS.items():
            print(f"  {key}) {label}")
        choice = input("Select an option [default 2]: ").strip().lower() or "2"
        if choice == "q":
            print("Exiting devtool.")
            break
        action = MENU_OPTIONS.get(choice)
        if not action:
            print("Invalid choice.")
            continue
        label, func = action
        print(f"\n[devtool] {label}")
        try:
            if func:
                func()
        except subprocess.CalledProcessError as exc:
            print(f"[devtool] Command failed with exit code {exc.returncode}")
        except KeyboardInterrupt:
            print("\n[devtool] Command interrupted.")


if __name__ == "__main__":
    main()
