import json
import os
import subprocess
import tempfile
from pathlib import Path

from robot.libraries.BuiltIn import BuiltIn

class GodotKeywords:
    """Robot Framework keywords for running Godot logic tests."""

    def __init__(self):
        self.repo_root = Path(__file__).resolve().parents[3]
        default_bin = self.repo_root / "tools" / "godot" / "godot4"
        self.godot_bin = Path(os.environ.get("GODOT_BIN", str(default_bin)))
        self.project_path = self.repo_root / "game"

    def run_godot_logic_tests(self):
        """Runs the entire Godot logic suite."""
        return self._invoke_runner()

    def run_godot_logic_case(self, case_path):
        """Runs a single Godot logic case."""
        data = self._invoke_runner(extra_args=[f"--case={case_path}"])
        tests = [t for t in data.get("tests", []) if t.get("case_file") == case_path]
        if not tests:
            raise AssertionError(f"No test results returned for {case_path}")
        case_result = tests[-1]
        bi = BuiltIn()
        if case_result.get("skipped"):
            bi.skip(case_result.get("message", "Case skipped"))
        if not case_result.get("passed", False):
            raise AssertionError(
                "Case failed:\n" + json.dumps(case_result, indent=2)
            )
        if os.environ.get("LOGIC_TEST_VERBOSE") and case_result.get("summary"):
            magenta = "\x1b[35m"
            reset = "\x1b[0m"
            summary_block = f"\n[logic] {case_path}:\n{magenta}{case_result['summary']}{reset}\n"
            bi.log_to_console(summary_block)
        return case_result

    def _invoke_runner(self, extra_args=None):
        if not self.godot_bin.exists():
            raise AssertionError(f"Godot binary not found at {self.godot_bin}")
        output_dir = Path(tempfile.mkdtemp(prefix="godot-tests-"))
        result_file = output_dir / "logic_results.json"
        env = os.environ.copy()
        env.setdefault("NIGHTFALL_DISABLE_FILE_LOGS", "1")
        godot_home = Path(env.get("GODOT_USER_HOME", self.repo_root / ".godot-test"))
        env["GODOT_USER_HOME"] = str(godot_home)
        logs_dir = godot_home / "app_userdata" / "Nightfall Survivor" / "logs"
        logs_dir.mkdir(parents=True, exist_ok=True)
        env.setdefault("XDG_DATA_HOME", str(self.repo_root / ".godot-data"))
        env.setdefault("DISABLE_API_MANAGER", "1")
        env.setdefault("NIGHTFALL_DISABLE_BOOT", "1")
        cmd = [
            str(self.godot_bin),
            "--headless",
            "--path",
            str(self.project_path),
            "--script",
            "res://tests/robot/logic_test_runner.gd",
            f"--result-file={result_file}",
        ]
        if extra_args:
            cmd.extend(extra_args)
        completed = subprocess.run(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            check=False,
            env=env,
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
