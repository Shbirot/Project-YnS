import tempfile
from pathlib import Path

from scripts.strip_debug import strip_file, strip_directory


def test_strip_debug_blocks(tmp_path: Path) -> None:
    source = tmp_path / "sample.gd"
    source.write_text(
        "var a = 1\n# DEBUG-ONLY-START\nDebugUtils.debug_log(\"trace\")\n# DEBUG-ONLY-END\nvar b = 2\n",
        encoding="utf-8",
    )
    dest = tmp_path / "out.gd"
    strip_file(source, dest)
    text = dest.read_text(encoding="utf-8")
    assert "# DEBUG-ONLY" not in text
    assert "DebugUtils.debug_log" not in text
    assert "var a" in text and "var b" in text


def test_strip_directory(tmp_path: Path) -> None:
    src_dir = tmp_path / "src"
    dst_dir = tmp_path / "dst"
    src_dir.mkdir()
    (src_dir / "foo.gd").write_text(
        "# DEBUG-ONLY-START\nprint('debug')\n# DEBUG-ONLY-END\nprint('keep')\n",
        encoding="utf-8",
    )
    strip_directory(src_dir, dst_dir)
    text = (dst_dir / "foo.gd").read_text(encoding="utf-8")
    assert "debug" not in text
    assert "keep" in text
