#!/usr/bin/env python3
"""Strip DEBUG markers and log helpers from GDScript files."""
from __future__ import annotations

import argparse
from pathlib import Path


def strip_file(source: Path, target: Path) -> None:
    text = source.read_text(encoding="utf-8").splitlines()
    output: list[str] = []
    skipping = False
    for line in text:
        if "# DEBUG-ONLY-START" in line:
            skipping = True
            continue
        if "# DEBUG-ONLY-END" in line:
            skipping = False
            continue
        if "DebugUtils.debug_log" in line or "NF_DEBUG_LOG" in line:
            continue
        if not skipping:
            output.append(line)
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text("\n".join(output) + ("\n" if output else ""), encoding="utf-8")


def strip_directory(source_dir: Path, dest_dir: Path) -> None:
    for path in source_dir.rglob("*.gd"):
        relative = path.relative_to(source_dir)
        target = dest_dir / relative
        strip_file(path, target)


def main() -> None:
    parser = argparse.ArgumentParser(description="Strip debug sections from GDScript files.")
    parser.add_argument("--src", default="game/src", help="Source directory containing .gd files")
    parser.add_argument("--dest", default="build/stripped/src", help="Destination directory for stripped files")
    args = parser.parse_args()

    source_dir = Path(args.src).resolve()
    dest_dir = Path(args.dest).resolve()
    if not source_dir.exists():
        raise SystemExit(f"[strip_debug] Source directory {source_dir} does not exist")
    strip_directory(source_dir, dest_dir)
    print(f"[strip_debug] Stripped scripts copied to {dest_dir}")


if __name__ == "__main__":
    main()
