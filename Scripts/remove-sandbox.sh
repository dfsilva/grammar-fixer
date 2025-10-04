#!/bin/bash

# Temporarily disable sandboxing for development
# This script modifies the built app to remove sandbox restrictions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

APP_PATH="$HOME/Library/Developer/Xcode/DerivedData/grammar-fixer-fcjvhhvcfzakzmavavyjfqhfumds/Build/Products/Debug/grammar-fixer.app"

echo "🔓 Removing sandbox restrictions for development..."

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
    echo "❌ App not found at: $APP_PATH"
    echo "🔍 Searching for app in DerivedData..."
    
    # Try to find the app in DerivedData
    DERIVED_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "grammar-fixer.app" -type d 2>/dev/null | head -1)
    
    if [ -n "$DERIVED_PATH" ]; then
        APP_PATH="$DERIVED_PATH"
        echo "📍 Found app at: $APP_PATH"
    else
        echo "❌ Could not find the built app"
        exit 1
    fi
fi

# Remove code signature to allow modification
echo "🗑️  Removing code signature..."
codesign --remove-signature "$APP_PATH"

# Create new entitlements without sandbox
echo "📝 Creating development entitlements..."
cat > /tmp/dev-entitlements.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.get-task-allow</key>
    <true/>
</dict>
</plist>
EOF

# Re-sign with development entitlements
echo "✍️  Re-signing with development entitlements..."
codesign --force --sign - --entitlements /tmp/dev-entitlements.plist "$APP_PATH"

echo "✅ App modified for development (no sandbox restrictions)"
echo "🚀 You can now run the app with network access"

# Clean up
rm /tmp/dev-entitlements.plist