#!/usr/bin/env bash
# Installs a local Android SDK + NDK under tools/android-sdk using Google's cmdline-tools.
set -euo pipefail
PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT:-"$PROJECT_ROOT/tools/android-sdk"}
CMDLINE_VERSION=${CMDLINE_VERSION:-"11076708"}
CMDLINE_ZIP="commandlinetools-linux-${CMDLINE_VERSION}_latest.zip"
CMDLINE_URL="https://dl.google.com/android/repository/${CMDLINE_ZIP}"
CMDLINE_DIR="$ANDROID_SDK_ROOT/cmdline-tools"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[install-android-sdk] '$1' is required but not installed or not on PATH" >&2
    exit 1
  fi
}

require_cmd curl
require_cmd unzip
require_cmd java

check_java_version() {
  local version_string major
  version_string=$(java -version 2>&1 | awk -F\" '/version/ {print $2; exit}')
  if [[ -z "$version_string" ]]; then
    echo "[install-android-sdk] Unable to determine Java version." >&2
    exit 1
  fi
  if [[ "$version_string" == 1.* ]]; then
    major=$(echo "$version_string" | cut -d. -f2)
  else
    major=${version_string%%.*}
  fi
  if (( major < 17 )); then
    echo "[install-android-sdk] Detected Java version $version_string (major $major). Java 17+ is required. Install a newer JDK (e.g., OpenJDK 17) and rerun." >&2
    exit 1
  fi
}

check_java_version

mkdir -p "$ANDROID_SDK_ROOT"

fix_cmdline_layout() {
  if [[ -d "$CMDLINE_DIR/latest-2" ]]; then
    echo "[install-android-sdk] Consolidating cmdline-tools 'latest-2' into 'latest'"
    rm -rf "$CMDLINE_DIR/latest"
    mv "$CMDLINE_DIR/latest-2" "$CMDLINE_DIR/latest"
  fi
}

if [[ ! -d "$CMDLINE_DIR/latest" ]]; then
  echo "[install-android-sdk] Fetching Android cmdline-tools from $CMDLINE_URL"
  tmp_zip=$(mktemp)
  curl -L "$CMDLINE_URL" -o "$tmp_zip"
  mkdir -p "$CMDLINE_DIR"
  unzip -q -o "$tmp_zip" -d "$ANDROID_SDK_ROOT"
  rm "$tmp_zip"
  # Zip extracts to cmdline-tools; move to cmdline-tools/latest to match sdkmanager expectations.
  if [[ -d "$ANDROID_SDK_ROOT/cmdline-tools" && ! -d "$CMDLINE_DIR/latest" ]]; then
    mv "$ANDROID_SDK_ROOT/cmdline-tools" "$ANDROID_SDK_ROOT/cmdline-tools-tmp"
    mkdir -p "$CMDLINE_DIR"
    mv "$ANDROID_SDK_ROOT/cmdline-tools-tmp" "$CMDLINE_DIR/latest"
  fi
fi

fix_cmdline_layout

SDKMANAGER_BIN="$CMDLINE_DIR/latest/bin/sdkmanager"
if [[ ! -x "$SDKMANAGER_BIN" ]]; then
  echo "[install-android-sdk] sdkmanager not found at $SDKMANAGER_BIN" >&2
  exit 1
fi

export ANDROID_HOME="$ANDROID_SDK_ROOT"
export ANDROID_SDK_ROOT="$ANDROID_SDK_ROOT"
export ANDROID_NDK_ROOT="$ANDROID_SDK_ROOT/ndk/25.2.9519653"

PACKAGES=(
  "platform-tools"
  "platforms;android-34"
  "build-tools;34.0.0"
  "ndk;25.2.9519653"
)

echo "[install-android-sdk] Installing packages: ${PACKAGES[*]}"
yes | "$SDKMANAGER_BIN" --sdk_root="$ANDROID_SDK_ROOT" "cmdline-tools;latest" >/dev/null
yes | "$SDKMANAGER_BIN" --sdk_root="$ANDROID_SDK_ROOT" "${PACKAGES[@]}"
yes | "$SDKMANAGER_BIN" --sdk_root="$ANDROID_SDK_ROOT" --licenses
fix_cmdline_layout

cat <<INFO

Android SDK installed under $ANDROID_SDK_ROOT
Add the following to your shell profile:
  export ANDROID_HOME="$ANDROID_SDK_ROOT"
  export ANDROID_SDK_ROOT="$ANDROID_SDK_ROOT"
  export ANDROID_NDK_ROOT="$ANDROID_SDK_ROOT/ndk/25.2.9519653"
  export PATH="\$ANDROID_HOME/platform-tools:\$ANDROID_HOME/cmdline-tools/latest/bin:\$PATH"

INFO
