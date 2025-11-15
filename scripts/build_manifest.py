#!/usr/bin/env python3
"""Generate SHA-256 manifest for critical config files."""
from __future__ import annotations

import hashlib
import json
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
GAME_DIR = REPO_ROOT / "game"
MANIFEST_PATH = GAME_DIR / "config" / "manifest.json"
STATIC_FILES = [
    "config/data/waves.json",
    "config/data/waves_stress.json",
]


def _hash_file(path: Path) -> str:
    digest = hashlib.sha256()
    digest.update(path.read_bytes())
    return digest.hexdigest()


def _collect_files() -> list[Path]:
    files = [GAME_DIR / rel for rel in STATIC_FILES]
    enemies_dir = GAME_DIR / "config" / "enemies"
    if enemies_dir.exists():
        for path in enemies_dir.rglob("*.tres"):
            files.append(path)
    return files


def build_manifest() -> None:
    entries: dict[str, dict[str, str]] = {}
    for file_path in _collect_files():
        if not file_path.exists():
            continue
        rel_path = file_path.relative_to(GAME_DIR).as_posix()
        entries[rel_path] = {"sha256": _hash_file(file_path)}
    MANIFEST_PATH.parent.mkdir(parents=True, exist_ok=True)
    MANIFEST_PATH.write_text(json.dumps(entries, indent=2), encoding="utf-8")
    print(f"[build_manifest] Wrote {len(entries)} entries to {MANIFEST_PATH}")


if __name__ == "__main__":
    build_manifest()
