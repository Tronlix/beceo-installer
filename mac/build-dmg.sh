#!/bin/bash
# Build BeCEO macOS DMG
# Run this on a Mac: ./mac/build-dmg.sh

set -e

APP_NAME="BeCEO"
VERSION="1.0.0-Beta"
DMG_NAME="${APP_NAME}-${VERSION}-macOS"
SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SOURCE_DIR/.." && pwd)"
BUILD_DIR="$ROOT_DIR/mac-build"
OUTPUT_DIR="$ROOT_DIR/output"

echo "Building $DMG_NAME.dmg..."

# Cleanup
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/$APP_NAME Installer"
mkdir -p "$OUTPUT_DIR"

# Copy files
cp "$SOURCE_DIR/install.command" "$BUILD_DIR/$APP_NAME Installer/Install BeCEO.command"
cp "$ROOT_DIR/beceo-V1Beta.tgz" "$BUILD_DIR/$APP_NAME Installer/"

# Make executable
chmod +x "$BUILD_DIR/$APP_NAME Installer/Install BeCEO.command"

# Create DMG
hdiutil create \
    -volname "$APP_NAME Installer" \
    -srcfolder "$BUILD_DIR/$APP_NAME Installer" \
    -ov \
    -format UDZO \
    "$OUTPUT_DIR/$DMG_NAME.dmg"

# Cleanup
rm -rf "$BUILD_DIR"

echo "Done! Output: output/$DMG_NAME.dmg"
