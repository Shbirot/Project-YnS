#!/bin/bash

# Simple Walk Animation Creator
# Creates a basic 4-frame walking animation from a single sprite using transformations
# This is a quick hack - real animations need properly drawn frames
# Usage: ./create_simple_walk_animation.sh <sprite.png> <output_spritesheet.png>

set -e

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <input_sprite.png> <output_spritesheet.png>"
    echo ""
    echo "Example:"
    echo "  $0 character_sprite.png character_walk_sheet.png"
    exit 1
fi

INPUT="$1"
OUTPUT="$2"

if [ ! -f "$INPUT" ]; then
    echo "Error: Input file not found: $INPUT"
    exit 1
fi

echo "Creating simple walk animation from: $INPUT"

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Frame 1: Slight tilt left, scale slightly smaller
echo "  [1/4] Creating frame 1 (tilt left)..."
convert "$INPUT" -background none \
    -rotate -3 \
    -resize 250x250 \
    -gravity center -extent 256x256 \
    "$TEMP_DIR/frame1.png"

# Frame 2: Neutral, slightly scaled up (mid-step)
echo "  [2/4] Creating frame 2 (neutral, lifted)..."
convert "$INPUT" -background none \
    -resize 258x258 \
    -gravity center -extent 256x256 \
    "$TEMP_DIR/frame2.png"

# Frame 3: Slight tilt right, scale slightly smaller
echo "  [3/4] Creating frame 3 (tilt right)..."
convert "$INPUT" -background none \
    -rotate 3 \
    -resize 250x250 \
    -gravity center -extent 256x256 \
    "$TEMP_DIR/frame3.png"

# Frame 4: Same as frame 2 (neutral)
echo "  [4/4] Creating frame 4 (neutral, lifted)..."
cp "$TEMP_DIR/frame2.png" "$TEMP_DIR/frame4.png"

# Combine into horizontal sprite sheet (4 frames x 256 = 1024 wide)
echo "  Combining into sprite sheet..."
convert "$TEMP_DIR/frame1.png" "$TEMP_DIR/frame2.png" \
        "$TEMP_DIR/frame3.png" "$TEMP_DIR/frame4.png" \
        +append "$OUTPUT"

echo "✓ Created: $OUTPUT (1024x256, 4 frames)"
echo ""
echo "Note: This is a simple transformation-based animation."
echo "For better results, generate proper walking frames with AI!"
