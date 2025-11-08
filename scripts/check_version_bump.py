#!/usr/bin/env python3
import subprocess
import sys
from pathlib import Path

VERSION_FILE = Path(__file__).resolve().parents[1] / ".VERSION"

def read_file(path: Path) -> str:
    return path.read_text().strip()


def file_changed() -> bool:
    try:
        diff = subprocess.check_output([
            "git",
            "diff",
            "HEAD~1",
            "--name-only",
            str(VERSION_FILE.relative_to(Path.cwd()))
        ], text=True)
    except subprocess.CalledProcessError as exc:
        print(exc.output)
        return False
    return bool(diff.strip())


def main() -> int:
    if not VERSION_FILE.exists():
        print(".VERSION file missing", file=sys.stderr)
        return 1
    if not file_changed():
        print("error: .VERSION must be updated for master merges", file=sys.stderr)
        return 1
    print(".VERSION bump detected")
    return 0

if __name__ == "__main__":
    sys.exit(main())
