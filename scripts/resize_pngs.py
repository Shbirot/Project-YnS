#!/usr/bin/env python3
"""Resize PNG assets to standardized dimensions."""
from pathlib import Path
from PIL import Image

REPO_ROOT = Path(__file__).resolve().parents[1]
ASSETS_DIR = REPO_ROOT / "game" / "src" / "shared" / "assets" / "poc"

# Size mapping based on asset type
SIZE_RULES = {
    "hero": (256, 256),
    "environmental_decorations": (256, 256),
    "animal": (128, 128),  # enemies
    "coin": (32, 32),
    "projectile": None,  # Skip - already good size
}

def get_target_size(png_path):
    """Determine target size based on file path."""
    rel_path = png_path.relative_to(ASSETS_DIR)
    parts = rel_path.parts

    # Check first directory level for category
    if len(parts) > 0:
        category = parts[0]
        if category in SIZE_RULES:
            return SIZE_RULES[category]

    # Default: no resize
    return None

def resize_image(png_path, target_size):
    """Resize a PNG to target dimensions using high-quality resampling."""
    with Image.open(png_path) as img:
        # Use LANCZOS for high-quality downsampling
        resized = img.resize(target_size, Image.Resampling.LANCZOS)
        resized.save(png_path)

def main():
    print("PNG Resize Tool\n" + "=" * 50)

    png_files = sorted(ASSETS_DIR.rglob("*.png"))

    resize_plan = {
        (256, 256): [],
        (128, 128): [],
        (32, 32): [],
        None: [],
    }

    # Build resize plan
    for png_path in png_files:
        target_size = get_target_size(png_path)
        resize_plan[target_size].append(png_path)

    # Show plan
    print("Resize Plan:")
    print(f"\n256x256 (Heroes, Decorations): {len(resize_plan[(256, 256)])} files")
    for p in resize_plan[(256, 256)]:
        print(f"  - {p.relative_to(ASSETS_DIR)}")

    print(f"\n128x128 (Enemies): {len(resize_plan[(128, 128)])} files")
    for p in resize_plan[(128, 128)]:
        print(f"  - {p.relative_to(ASSETS_DIR)}")

    print(f"\n32x32 (Coins): {len(resize_plan[(32, 32)])} files")
    for p in resize_plan[(32, 32)]:
        print(f"  - {p.relative_to(ASSETS_DIR)}")

    print(f"\nSkipped (No changes): {len(resize_plan[None])} files")
    for p in resize_plan[None]:
        print(f"  - {p.relative_to(ASSETS_DIR)}")

    # Confirm
    print("\n" + "=" * 50)
    response = input("Proceed with resize? (y/n): ").strip().lower()

    if response != 'y':
        print("Cancelled.")
        return

    # Execute resize
    print("\nResizing...")
    for target_size, files in resize_plan.items():
        if target_size is None:
            continue

        for png_path in files:
            try:
                resize_image(png_path, target_size)
                print(f"[OK] {png_path.relative_to(ASSETS_DIR)} -> {target_size[0]}x{target_size[1]}")
            except Exception as e:
                print(f"[FAIL] {png_path.relative_to(ASSETS_DIR)}: {e}")

    print("\n" + "=" * 50)
    print("Resize complete!")

if __name__ == "__main__":
    main()
