#!/bin/bash

# Sprite Sheet Creator
# Combines multiple PNG frames into a horizontal sprite sheet
# Usage: ./create_spritesheet.sh <output.png> <frame1.png> <frame2.png> ...

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ "$#" -lt 3 ]; then
    echo -e "${RED}Error: Not enough arguments${NC}"
    echo "Usage: $0 <output_spritesheet.png> <frame1.png> <frame2.png> [frame3.png] ..."
    echo ""
    echo "Examples:"
    echo "  $0 walk_sheet.png walk1.png walk2.png walk3.png walk4.png"
    echo "  $0 idle_sheet.png idle1.png idle2.png"
    echo ""
    echo "Creates a horizontal sprite sheet from input frames (left to right)"
    exit 1
fi

OUTPUT="$1"
shift
FRAMES=("$@")

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Sprite Sheet Creator${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "Output file: ${YELLOW}${OUTPUT}${NC}"
echo -e "Frame count: ${GREEN}${#FRAMES[@]}${NC}"
echo ""

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo -e "${RED}Error: ImageMagick 'convert' command not found${NC}"
    echo "Install with: sudo apt-get install imagemagick"
    exit 1
fi

# Validate all input frames exist
MISSING=0
for frame in "${FRAMES[@]}"; do
    if [ ! -f "$frame" ]; then
        echo -e "${RED}✗ Missing:${NC} $frame"
        ((MISSING++))
    fi
done

if [ "$MISSING" -gt 0 ]; then
    echo ""
    echo -e "${RED}Error: $MISSING frame file(s) not found${NC}"
    exit 1
fi

# Get dimensions of first frame (all should match)
FIRST_FRAME="${FRAMES[0]}"
DIMENSIONS=$(identify -format "%wx%h" "$FIRST_FRAME" 2>/dev/null)
WIDTH=$(echo "$DIMENSIONS" | cut -d'x' -f1)
HEIGHT=$(echo "$DIMENSIONS" | cut -d'x' -f2)

echo -e "Frame size: ${WIDTH}x${HEIGHT}"
echo -e "Sheet size: $((WIDTH * ${#FRAMES[@]}))x${HEIGHT}"
echo ""

# Create temp directory for normalized frames
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Normalize all frames to same size and ensure transparency
echo "Normalizing frames..."
for i in "${!FRAMES[@]}"; do
    frame="${FRAMES[$i]}"
    frame_num=$((i + 1))
    echo -n "  [$frame_num/${#FRAMES[@]}] Processing $(basename "$frame")... "

    if convert "$frame" -resize ${WIDTH}x${HEIGHT}! -background none -flatten "$TEMP_DIR/frame_${i}.png" 2>/dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗ FAILED${NC}"
        exit 1
    fi
done

# Combine frames horizontally
echo ""
echo -n "Creating sprite sheet... "
if convert "$TEMP_DIR"/frame_*.png +append "$OUTPUT" 2>/dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗ FAILED${NC}"
    exit 1
fi

# Get output file size
FILESIZE=$(du -h "$OUTPUT" | cut -f1)

echo ""
echo -e "${GREEN}✓ Success!${NC}"
echo -e "Created: ${YELLOW}${OUTPUT}${NC}"
echo -e "Size: ${FILESIZE}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Import sprite sheet into Godot"
echo "2. Create SpriteFrames resource"
echo "3. Use 'Add Frames from Sprite Sheet' option"
echo "4. Configure grid: ${#FRAMES[@]} columns x 1 row"
