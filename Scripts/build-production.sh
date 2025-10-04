#!/bin/bash

# Grammar Fixer Production Build Script
# Builds the app in Release configuration and removes sandbox restrictions for production use

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_NAME="grammar-fixer"
SCHEME_NAME="grammar-fixer"
BUILD_DIR="$PROJECT_DIR/build"
DERIVED_DATA_PATH="$BUILD_DIR/DerivedData"
RELEASE_APP_PATH="$DERIVED_DATA_PATH/Build/Products/Release/grammar-fixer.app"

echo "🏭 Grammar Fixer Production Build & Run"
echo "Project Directory: $PROJECT_DIR"

# Step 1: Kill any running instances
echo "🛑 Killing any running instances of $PROJECT_NAME..."
pkill -f "$PROJECT_NAME" 2>/dev/null || echo "   No running instances found"
sleep 1

# Step 2: Clean and prepare build directory
echo "🧹 Cleaning previous builds..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Step 3: Build the project in Release configuration
echo "🔨 Building $PROJECT_NAME (Release configuration)..."
cd "$PROJECT_DIR"

xcodebuild -project "$PROJECT_NAME.xcodeproj" \
           -scheme "$SCHEME_NAME" \
           -configuration Release \
           -derivedDataPath "$DERIVED_DATA_PATH" \
           build

if [ $? -eq 0 ]; then
    echo "✅ Release build successful!"
else
    echo "❌ Release build failed!"
    exit 1
fi

# Step 4: Remove sandbox restrictions from the Release build
echo "🔓 Removing sandbox restrictions from Release build..."

# Check if Release app exists
if [ ! -d "$RELEASE_APP_PATH" ]; then
    echo "❌ Release app not found at: $RELEASE_APP_PATH"
    echo "🔍 Searching for Release app in DerivedData..."
    
    # Try to find the app in DerivedData Release folder
    FOUND_PATH=$(find "$DERIVED_DATA_PATH" -path "*/Release/grammar-fixer.app" -type d 2>/dev/null | head -1)
    
    if [ -n "$FOUND_PATH" ]; then
        RELEASE_APP_PATH="$FOUND_PATH"
        echo "📍 Found Release app at: $RELEASE_APP_PATH"
    else
        echo "❌ Could not find the Release build"
        exit 1
    fi
fi

# Remove code signature to allow modification
echo "🗑️  Removing code signature from Release build..."
codesign --remove-signature "$RELEASE_APP_PATH"

# Create production entitlements without sandbox but with accessibility support
echo "📝 Creating production entitlements (no sandbox + accessibility)..."
cat > /tmp/production-entitlements.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.get-task-allow</key>
    <false/>
    <key>com.apple.security.cs.allow-jit</key>
    <true/>
    <key>com.apple.security.cs.allow-unsigned-executable-memory</key>
    <true/>
    <key>com.apple.security.cs.disable-library-validation</key>
    <true/>
    <key>com.apple.security.automation.apple-events</key>
    <true/>
</dict>
</plist>
EOF

# Re-sign with production entitlements (no sandbox)
echo "✍️  Re-signing with production entitlements..."
codesign --force --sign - --entitlements /tmp/production-entitlements.plist "$RELEASE_APP_PATH"

# Try to preserve bundle identifier and other metadata to help with permissions
echo "🔍 Checking app bundle metadata..."
BUNDLE_ID=$(plutil -p "$RELEASE_APP_PATH/Contents/Info.plist" | grep CFBundleIdentifier | cut -d'"' -f4)
echo "   Bundle ID: $BUNDLE_ID"

echo "✅ Release app modified for production (no sandbox restrictions)"

# Step 5: Copy the Release app to build directory for easier access
echo "📁 Copying Release app to build directory..."
cp -R "$RELEASE_APP_PATH" "$BUILD_DIR/"
FINAL_APP_PATH="$BUILD_DIR/grammar-fixer.app"

# Step 6: Install the app to /Applications
echo "💾 Installing Grammar Fixer to /Applications..."
INSTALLED_APP_PATH="/Applications/Grammar Fixer.app"

# Remove existing installation if it exists
if [ -d "$INSTALLED_APP_PATH" ]; then
    echo "🗑️  Removing existing installation..."
    rm -rf "$INSTALLED_APP_PATH"
fi

# Copy the app to Applications folder
echo "📦 Installing to $INSTALLED_APP_PATH..."
cp -R "$FINAL_APP_PATH" "$INSTALLED_APP_PATH"

if [ -d "$INSTALLED_APP_PATH" ]; then
    echo "✅ Successfully installed to /Applications"
    LAUNCH_APP_PATH="$INSTALLED_APP_PATH"
else
    echo "❌ Installation to /Applications failed, using build directory version"
    LAUNCH_APP_PATH="$FINAL_APP_PATH"
fi

# Step 7: Display build information
echo ""
echo "📊 Build Information:"
if [ -f "$FINAL_APP_PATH/Contents/Info.plist" ]; then
    VERSION=$(plutil -p "$FINAL_APP_PATH/Contents/Info.plist" | grep CFBundleShortVersionString | cut -d'"' -f4)
    BUILD_NUMBER=$(plutil -p "$FINAL_APP_PATH/Contents/Info.plist" | grep CFBundleVersion | cut -d'"' -f4)
    echo "   Version: $VERSION ($BUILD_NUMBER)"
    echo "   Configuration: Release"
    echo "   Sandbox: Disabled"
    echo "   Installed: $LAUNCH_APP_PATH"
fi

echo ""
echo "🎯 Production app ready and installed!"
echo "   Build copy: $FINAL_APP_PATH"
echo "   Installed: $LAUNCH_APP_PATH"
echo ""

# Step 8: Ask user if they want to run the app immediately
read -p "🚀 Run the installed app now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🖥️  Launching Grammar Fixer from /Applications (background)..."
    
    # Run the installed app in the background using 'open' command
    open "$LAUNCH_APP_PATH"
    
    # Give it a moment to launch
    sleep 2
    
    # Check if the app is running
    if pgrep -f "grammar-fixer" > /dev/null; then
        echo "✅ Grammar Fixer is now running in the background"
        echo "   Process ID: $(pgrep -f "grammar-fixer")"
        echo "   To stop: pkill -f 'grammar-fixer'"
        echo "   Installed at: $LAUNCH_APP_PATH"
        echo ""
        echo "🔐 ACCESSIBILITY PERMISSIONS NOTICE:"
        echo "   If accessibility features aren't working, you may need to:"
        echo "   1. Open System Preferences/Settings → Privacy & Security"
        echo "   2. Go to Accessibility section"
        echo "   3. Remove any existing 'Grammar Fixer' entries"
        echo "   4. Click '+' and add the installed app: $LAUNCH_APP_PATH"
        echo "   5. Restart the app after granting permissions"
        echo ""
        echo "   This is needed because re-signing changes the app's security identity."
    else
        echo "⚠️  App launched but may not be running yet"
        echo ""
        echo "🔐 ACCESSIBILITY PERMISSIONS REMINDER:"
        echo "   Don't forget to grant accessibility permissions in System Preferences"
        echo "   if the app needs to read text from other applications."
    fi
else
    echo "ℹ️  To run later from Applications: open '$LAUNCH_APP_PATH'"
    echo "ℹ️  Or from Spotlight/Launchpad: Search for 'Grammar Fixer'"
    echo "ℹ️  Or from build directory: open '$FINAL_APP_PATH'"
    echo ""
    echo "🔐 ACCESSIBILITY PERMISSIONS REMINDER:"
    echo "   When you first run the app, grant accessibility permissions in:"
    echo "   System Preferences/Settings → Privacy & Security → Accessibility"
    echo "   Add the installed app: $LAUNCH_APP_PATH"
fi

# Clean up temporary files
rm -f /tmp/production-entitlements.plist

echo ""
echo "🎉 Production build complete!"