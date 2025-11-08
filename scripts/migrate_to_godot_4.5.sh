#!/bin/bash
set -e

# --- Configuration ---
GODOT_VERSION="4.5.1"
GODOT_DOWNLOAD_URL="https://github.com/godotengine/godot/releases/download/4.5.1-stable/Godot_v4.5.1-stable_linux.x86_64.zip"
GODOT_ZIP_FILE="godot_4.5.1.zip"
GODOT_INSTALL_PATH="tools/godot/godot4"

STEAM_PLUGIN_URL="https://codeberg.org/godotsteam/godotsteam/releases/download/v4.16.1/linux64-g451-s162-gs4161.tar.xz"
STEAM_ARCHIVE_FILE="godotsteam_4.16.1.tar.xz"
ADDONS_DIR="game/addons"

PROJECT_FILE="game/project.godot"

# --- Migration Steps ---
echo "--- Starting Godot 4.5 Migration ---"

# 1. Download Godot 4.5
echo "[1/5] Downloading Godot v${GODOT_VERSION}..."
wget -O "$GODOT_ZIP_FILE" "$GODOT_DOWNLOAD_URL"
echo "Download complete."

# 2. Replace Godot Binary
echo "[2/5] Replacing Godot binary..."
unzip -o "$GODOT_ZIP_FILE"
# The zip extracts to a folder like Godot_v4.5-stable_linux.x86_64
# We need to find the executable and move it.
EXECUTABLE_NAME=$(unzip -l "$GODOT_ZIP_FILE" | grep -o 'Godot_v[0-9\.]*-stable_linux\.x86_64' | head -n 1)
if [ -z "$EXECUTABLE_NAME" ]; then
    echo "Error: Could not find Godot executable in the downloaded archive."
    exit 1
fi
mv "$EXECUTABLE_NAME" "$GODOT_INSTALL_PATH"
chmod +x "$GODOT_INSTALL_PATH"
echo "Godot binary replaced at ${GODOT_INSTALL_PATH}."

# 3. Download GodotSteam for Godot 4.5
echo "[3/5] Downloading GodotSteam for Godot 4.5..."
wget -O "$STEAM_ARCHIVE_FILE" "$STEAM_PLUGIN_URL"
echo "Download complete."

# 4. Install GodotSteam Plugin
echo "[4/5] Installing GodotSteam plugin..."
mkdir -p "$ADDONS_DIR"
tar -xf "$STEAM_ARCHIVE_FILE" -C "$ADDONS_DIR"
echo "Plugin installed to ${ADDONS_DIR}."

# 5. Update Project Version
echo "[5/5] Updating project.godot to version 4.5..."
sed -i 's|config_version=.*|config_version=5|' "$PROJECT_FILE"
# This is a best-effort attempt. Godot 4.5 might use a different format.
# The editor will handle the full conversion.
echo "Project file updated."

# --- Cleanup ---
echo "Cleaning up downloaded files..."
rm "$GODOT_ZIP_FILE"
rm "$STEAM_ARCHIVE_FILE"
rm -rf Godot_v*-stable_linux.x86_64 # Clean up extracted folder

# --- Final Instructions ---
echo ""
echo "--- Migration Script Finished ---"
echo "IMPORTANT NEXT STEPS:"
echo "1. This script was run on your current branch. It is highly recommended to test this on a separate branch first."
echo "2. Open the Godot editor (e.g., by running './scripts/edit_project.sh')."
echo "3. Godot will prompt you to convert the project. Please confirm and let it complete."
echo "4. After conversion, run the test suite ('./run_tests.sh') to check for any regressions."
echo ""
