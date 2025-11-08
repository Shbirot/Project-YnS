import json
import os
import subprocess
import tempfile
from pathlib import Path

class GodotKeywords:
    """Robot Framework keywords for running Godot logic tests."""

    def __init__(self):
        self.repo_root = Path(__file__).resolve().parents[3]
        default_bin = self.repo_root / "tools" / "godot" / "godot4"
        self.godot_bin = Path(os.environ.get("GODOT_BIN", str(default_bin)))
        self.project_path = self.repo_root / "game"

    def run_godot_logic_tests(self):
        """Runs the Godot logic test runner and returns the parsed results."""
        if not self.godot_bin.exists():
            raise AssertionError(f"Godot binary not found at {self.godot_bin}")
        output_dir = Path(tempfile.mkdtemp(prefix="godot-tests-"))
        result_file = output_dir / "logic_results.json"
        cmd = [
            str(self.godot_bin),
            "--headless",
            "--path",
            str(self.project_path),
            "--script",
            "res://tests/robot/logic_test_runner.gd",
            f"--result-file={result_file}"
        ]
        completed = subprocess.run(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            check=False,
        )
        if completed.returncode != 0:
            raise AssertionError(
                "Godot logic tests failed:\n" + completed.stdout
            )
        if not result_file.exists():
            raise AssertionError("Logic result file not produced")
        data = json.loads(result_file.read_text())
        if not data.get("success", False):
            failures = [t for t in data.get("tests", []) if not t.get("passed", True)]
            raise AssertionError(
                "Logic tests reported failures:\n" + json.dumps(failures, indent=2)
            )
        return data
