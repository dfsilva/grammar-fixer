#!/bin/bash

# Grammar Fixer Development Quick Runner
# Kills any running instances, builds debug version, and runs the app

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_NAME="grammar-fixer"
SCHEME_NAME="grammar-fixer"

echo "🔥 Grammar Fixer Development Runner"
echo "Project Directory: $PROJECT_DIR"

# Step 1: Kill any running instances
echo "🛑 Killing any running instances of $PROJECT_NAME..."
pkill -f "$PROJECT_NAME" 2>/dev/null || echo "   No running instances found"
sleep 1

# Step 2: Build the project (Debug configuration)
echo "🔨 Building $PROJECT_NAME (Debug)..."
cd "$PROJECT_DIR"

xcodebuild -project "$PROJECT_NAME.xcodeproj" \
           -scheme "$SCHEME_NAME" \
           -configuration Debug \
           build

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
else
    echo "❌ Build failed!"
    exit 1
fi

# Step 3: Remove sandbox restrictions for network access
echo "🔓 Removing sandbox restrictions..."
"$SCRIPT_DIR/remove-sandbox.sh"

# Step 4: Run the app with console output
echo "🚀 Launching $PROJECT_NAME with console output..."

# Dynamically find the most recently built app in DerivedData
echo "🔍 Finding the latest built app in DerivedData..."
DERIVED_PATH=$(find ~/Library/Developer/Xcode/DerivedData/grammar-fixer-*/Build/Products/Debug/grammar-fixer.app -type d 2>/dev/null | head -1)

if [ -z "$DERIVED_PATH" ]; then
    echo "❌ Could not find the built app in DerivedData"
    echo "💡 Try building the project first with: xcodebuild -project grammar-fixer.xcodeproj -scheme grammar-fixer -configuration Debug build"
    exit 1
fi

echo "📍 Found app at: $DERIVED_PATH"

# Kill any existing instances first
pkill -f "$PROJECT_NAME" 2>/dev/null || true
sleep 1

# Run the app executable directly to see console output
EXECUTABLE_PATH="$DERIVED_PATH/Contents/MacOS/grammar-fixer"
if [ -f "$EXECUTABLE_PATH" ]; then
    echo "🖥️  Running with console output (Ctrl+C to stop)..."
    "$EXECUTABLE_PATH"
else
    echo "❌ Executable not found at: $EXECUTABLE_PATH"
    exit 1
fi