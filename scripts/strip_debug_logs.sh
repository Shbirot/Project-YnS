#!/bin/bash

# Script to strip debug logs from production builds
# Removes all code between DEBUG-ONLY-START and DEBUG-ONLY-END markers

set -e

GAME_DIR="${1:-game}"

echo "Stripping debug logs from $GAME_DIR..."

# Find all .gd files
find "$GAME_DIR" -name "*.gd" -type f | while read -r file; do
    # Check if file contains debug markers
    if grep -q "DEBUG-ONLY-START" "$file"; then
        echo "Processing: $file"

        # Create backup
        cp "$file" "$file.bak"

        # Remove debug sections using sed
        # This removes everything between DEBUG-ONLY-START and DEBUG-ONLY-END including the markers
        sed -i '/# DEBUG-ONLY-START/,/# DEBUG-ONLY-END/d' "$file"

        echo "  Stripped debug sections from $file"
    fi
done

echo "Debug log stripping complete!"
echo "Note: Backups saved as .gd.bak files"
echo ""
echo "To restore from backups, run:"
echo "  find $GAME_DIR -name '*.gd.bak' -exec sh -c 'mv \"\$1\" \"\${1%.bak}\"' _ {} \\;"
