#!/bin/bash

# Sprite Batch Processor
# Converts JPG images to game-ready PNG sprites with glow maps and portraits
# Usage: ./process_sprites.sh <directory_path>

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if directory argument provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: No directory specified${NC}"
    echo "Usage: $0 <directory_path>"
    echo ""
    echo "Example:"
    echo "  $0 /path/to/jpeg/files"
    echo "  $0 ~/Downloads/character_sprites"
    exit 1
fi

INPUT_DIR="$1"

# Check if directory exists
if [ ! -d "$INPUT_DIR" ]; then
    echo -e "${RED}Error: Directory does not exist: ${INPUT_DIR}${NC}"
    exit 1
fi

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo -e "${RED}Error: ImageMagick 'convert' command not found${NC}"
    echo "Install with: sudo apt-get install imagemagick"
    exit 1
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Sprite Batch Processor${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "Input directory: ${YELLOW}${INPUT_DIR}${NC}"
echo ""

# Count JPG files
JPG_COUNT=$(find "$INPUT_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) | wc -l)

if [ "$JPG_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}Warning: No JPG/JPEG files found in directory${NC}"
    exit 0
fi

echo -e "Found ${GREEN}${JPG_COUNT}${NC} JPG file(s) to process"
echo ""

# Process each JPG file
PROCESSED=0
FAILED=0

# Use find to get all JPG files
while IFS= read -r -d '' jpg_file; do

    # Get filename without extension
    filename=$(basename "$jpg_file")
    basename="${filename%.*}"

    echo -e "${BLUE}Processing:${NC} ${filename}"

    # Define output filenames
    sprite_png="${INPUT_DIR}/${basename}_sprite.png"
    glow_png="${INPUT_DIR}/${basename}_glow.png"
    portrait_png="${INPUT_DIR}/${basename}_portrait.png"

    # Check if outputs already exist
    if [ -f "$sprite_png" ] && [ -f "$glow_png" ] && [ -f "$portrait_png" ]; then
        echo -e "  ${YELLOW}⚠${NC}  Already processed (files exist), skipping..."
        echo ""
        continue
    fi

    # Process sprite (convert to PNG and resize to 256x256)
    echo -n "  [1/3] Creating sprite PNG (256x256)... "
    if convert "$jpg_file" -resize 256x256 -background none "$sprite_png" 2>/dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗ FAILED${NC}"
        ((FAILED++))
        continue
    fi

    # Create glow map (grayscale with high contrast)
    echo -n "  [2/3] Creating glow map... "
    if convert "$sprite_png" -colorspace Gray -auto-level -contrast -contrast "$glow_png" 2>/dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗ FAILED${NC}"
        ((FAILED++))
        continue
    fi

    # Create portrait (crop upper 70% and resize to 256x256)
    echo -n "  [3/3] Creating portrait (256x256)... "
    if convert "$sprite_png" -gravity North -crop 256x180+0+0 +repage -resize 256x256! "$portrait_png" 2>/dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗ FAILED${NC}"
        ((FAILED++))
        continue
    fi

    echo -e "  ${GREEN}✓ Complete!${NC} Generated 3 files:"
    echo -e "    • ${basename}_sprite.png"
    echo -e "    • ${basename}_glow.png"
    echo -e "    • ${basename}_portrait.png"
    echo ""

    ((PROCESSED++))
done < <(find "$INPUT_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) -print0)

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Total JPGs found:     ${JPG_COUNT}"
echo -e "Successfully processed: ${GREEN}${PROCESSED}${NC}"
if [ "$FAILED" -gt 0 ]; then
    echo -e "Failed:                 ${RED}${FAILED}${NC}"
fi
echo -e "Output location:      ${YELLOW}${INPUT_DIR}${NC}"
echo ""

if [ "$PROCESSED" -gt 0 ]; then
    echo -e "${GREEN}Done! Generated $((PROCESSED * 3)) PNG files total.${NC}"
else
    echo -e "${YELLOW}No new files processed.${NC}"
fi
