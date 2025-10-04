#!/bin/bash

# Grammar Fixer Build Script
# This script builds the Grammar Fixer app and prepares it for distribution

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_NAME="grammar-fixer"
SCHEME_NAME="grammar-fixer"
BUILD_DIR="$PROJECT_DIR/build"
ARCHIVE_PATH="$BUILD_DIR/$PROJECT_NAME.xcarchive"
APP_PATH="$BUILD_DIR/$PROJECT_NAME.app"

echo "🚀 Building Grammar Fixer..."
echo "Script Directory: $SCRIPT_DIR"
echo "Project Directory: $PROJECT_DIR"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Build the project
echo "🔨 Building project..."
cd "$PROJECT_DIR"

xcodebuild -project "$PROJECT_NAME.xcodeproj" \
           -scheme "$SCHEME_NAME" \
           -configuration Release \
           -derivedDataPath "$BUILD_DIR/DerivedData" \
           -archivePath "$ARCHIVE_PATH" \
           archive

# Export the app
echo "📦 Exporting app..."
xcodebuild -exportArchive \
           -archivePath "$ARCHIVE_PATH" \
           -exportPath "$BUILD_DIR" \
           -exportOptionsPlist "Scripts/ExportOptions.plist"

# Create DMG (optional)
if command -v create-dmg >/dev/null 2>&1; then
    echo "💿 Creating DMG..."
    create-dmg \
        --volname "Grammar Fixer" \
        --window-pos 200 120 \
        --window-size 600 300 \
        --icon-size 100 \
        --icon "$PROJECT_NAME.app" 175 120 \
        --hide-extension "$PROJECT_NAME.app" \
        --app-drop-link 425 120 \
        "$BUILD_DIR/$PROJECT_NAME.dmg" \
        "$BUILD_DIR/"
else
    echo "⚠️  create-dmg not found. Install with: brew install create-dmg"
fi

echo "✅ Build complete!"
echo "App location: $BUILD_DIR/$PROJECT_NAME.app"

# Show build information
if [ -f "$BUILD_DIR/$PROJECT_NAME.app/Contents/Info.plist" ]; then
    VERSION=$(plutil -p "$BUILD_DIR/$PROJECT_NAME.app/Contents/Info.plist" | grep CFBundleShortVersionString | cut -d'"' -f4)
    BUILD=$(plutil -p "$BUILD_DIR/$PROJECT_NAME.app/Contents/Info.plist" | grep CFBundleVersion | cut -d'"' -f4)
    echo "Version: $VERSION ($BUILD)"
fi

echo ""
echo "🎉 Grammar Fixer is ready!"
echo "To install: Drag the app to /Applications"
echo "To distribute: Use the DMG file (if created)"