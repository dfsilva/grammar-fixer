#!/bin/bash

# Grammar Fixer Accessibility Permissions Reset Script
# Helps reset and re-grant accessibility permissions for the production build

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
APP_PATH="$PROJECT_DIR/build/grammar-fixer.app"

echo "🔐 Grammar Fixer Accessibility Permissions Helper"
echo ""

# Check if the production app exists
if [ ! -d "$APP_PATH" ]; then
    echo "❌ Production app not found at: $APP_PATH"
    echo "   Please run './Scripts/build-production.sh' first"
    exit 1
fi

# Get app bundle information
BUNDLE_ID=$(plutil -p "$APP_PATH/Contents/Info.plist" | grep CFBundleIdentifier | cut -d'"' -f4)
APP_NAME=$(plutil -p "$APP_PATH/Contents/Info.plist" | grep CFBundleName | cut -d'"' -f4)

echo "📱 App Information:"
echo "   Name: $APP_NAME"
echo "   Bundle ID: $BUNDLE_ID"
echo "   Path: $APP_PATH"
echo ""

# Kill any running instances
echo "🛑 Stopping any running instances..."
pkill -f "grammar-fixer" 2>/dev/null || echo "   No running instances found"
sleep 1

echo "🔧 Accessibility Permissions Reset Instructions:"
echo ""
echo "1️⃣  Open System Preferences/Settings"
echo "2️⃣  Go to 'Privacy & Security' → 'Accessibility'"
echo "3️⃣  Look for any entries with 'grammar-fixer' or '$APP_NAME'"
echo "4️⃣  Remove all existing entries (click '-' button)"
echo "5️⃣  Click '+' to add a new entry"
echo "6️⃣  Navigate to and select: $APP_PATH"
echo "7️⃣  Make sure the toggle is ON for the new entry"
echo ""

# Try to open System Preferences to the right section (macOS version dependent)
echo "🖥️  Attempting to open System Preferences..."
if command -v osascript >/dev/null 2>&1; then
    # Try to open Privacy & Security pane
    osascript -e 'tell application "System Preferences" to activate' \
              -e 'tell application "System Preferences" to reveal anchor "Privacy_Accessibility" of pane "com.apple.preference.security"' 2>/dev/null || \
    osascript -e 'tell application "System Settings" to activate' 2>/dev/null || \
    echo "   Please open System Preferences/Settings manually"
else
    echo "   Please open System Preferences/Settings manually"
fi

echo ""
read -p "Press ENTER after you've updated the accessibility permissions..."

echo ""
echo "🚀 Testing the app with new permissions..."
open "$APP_PATH"

sleep 3

if pgrep -f "grammar-fixer" > /dev/null; then
    echo "✅ Grammar Fixer is running!"
    echo "   Process ID: $(pgrep -f "grammar-fixer")"
    echo "   Test the accessibility features now"
    echo "   To stop: pkill -f 'grammar-fixer'"
else
    echo "⚠️  App may not be running. Try launching it manually:"
    echo "   open '$APP_PATH'"
fi

echo ""
echo "💡 Pro Tip: If accessibility still doesn't work:"
echo "   - Restart your Mac after granting permissions"
echo "   - Make sure the app path in Accessibility settings matches exactly:"
echo "     $APP_PATH"