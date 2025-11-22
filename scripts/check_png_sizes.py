#!/usr/bin/env python3
"""Check PNG dimensions in the project."""
from pathlib import Path
from PIL import Image

REPO_ROOT = Path(__file__).resolve().parents[1]
ASSETS_DIR = REPO_ROOT / "game" / "src" / "shared" / "assets" / "poc"

def main():
    print("PNG Dimensions Report\n" + "=" * 50)

    png_files = sorted(ASSETS_DIR.rglob("*.png"))

    sizes = {}
    for png_path in png_files:
        try:
            with Image.open(png_path) as img:
                size = f"{img.width}x{img.height}"
                rel_path = png_path.relative_to(ASSETS_DIR)
                print(f"{rel_path}: {size}")

                if size not in sizes:
                    sizes[size] = []
                sizes[size].append(rel_path)
        except Exception as e:
            print(f"Error reading {png_path}: {e}")

    print("\n" + "=" * 50)
    print("Size Distribution:")
    for size, files in sorted(sizes.items()):
        print(f"  {size}: {len(files)} file(s)")

    print(f"\nTotal: {len(png_files)} PNG files")
    print(f"Unique sizes: {len(sizes)}")

if __name__ == "__main__":
    main()
