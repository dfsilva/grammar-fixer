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
APP_PATH="$HOME/Library/Developer/Xcode/DerivedData/grammar-fixer-fcjvhhvcfzakzmavavyjfqhfumds/Build/Products/Debug/grammar-fixer.app"

if [ -d "$APP_PATH" ]; then
    # Kill any existing instances first
    pkill -f "$PROJECT_NAME" 2>/dev/null || true
    sleep 1
    
    # Run the app executable directly to see console output
    EXECUTABLE_PATH="$APP_PATH/Contents/MacOS/grammar-fixer"
    if [ -f "$EXECUTABLE_PATH" ]; then
        echo "🖥️  Running with console output (Ctrl+C to stop)..."
        "$EXECUTABLE_PATH"
    else
        echo "❌ Executable not found at: $EXECUTABLE_PATH"
        exit 1
    fi
else
    echo "❌ App not found at expected location: $APP_PATH"
    echo "🔍 Searching for app in DerivedData..."
    
    # Try to find the app in DerivedData
    DERIVED_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "grammar-fixer.app" -type d 2>/dev/null | head -1)
    
    if [ -n "$DERIVED_PATH" ]; then
        echo "📍 Found app at: $DERIVED_PATH"
        
        # Kill any existing instances first
        pkill -f "$PROJECT_NAME" 2>/dev/null || true
        sleep 1
        
        # Run the app executable directly
        EXECUTABLE_PATH="$DERIVED_PATH/Contents/MacOS/grammar-fixer"
        if [ -f "$EXECUTABLE_PATH" ]; then
            echo "🖥️  Running with console output (Ctrl+C to stop)..."
            "$EXECUTABLE_PATH"
        else
            echo "❌ Executable not found at: $EXECUTABLE_PATH"
            exit 1
        fi
    else
        echo "❌ Could not find the built app"
        exit 1
    fi
fi