#!/bin/bash

# Grammar Fixer Development Helper
# Quick commands for development workflow

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"

case "$1" in
    "clean")
        echo "🧹 Cleaning build artifacts..."
        rm -rf build/
        rm -rf DerivedData/
        xcodebuild clean -project grammar-fixer.xcodeproj
        echo "✅ Clean complete"
        ;;
    
    "build")
        echo "🔨 Building Grammar Fixer..."
        ./Scripts/build.sh
        
        # Remove sandbox restrictions for development
        if [ -d "build/grammar-fixer.app" ]; then
            echo "🔓 Removing sandbox restrictions for development..."
            ./Scripts/remove-sandbox.sh "build/grammar-fixer.app"
        fi
        ;;
    
    "run")
        echo "🚀 Running Grammar Fixer..."
        
        # Ensure sandbox is removed before running
        if [ -d "build/grammar-fixer.app" ]; then
            ./Scripts/remove-sandbox.sh "build/grammar-fixer.app" >/dev/null 2>&1
        fi
        
        open build/grammar-fixer.app
        ;;
    
    "install")
        echo "📲 Installing to /Applications..."
        if [ -d "build/grammar-fixer.app" ]; then
            cp -R "build/grammar-fixer.app" "/Applications/"
            echo "✅ Installed successfully"
        else
            echo "❌ Build first with: ./Scripts/dev.sh build"
        fi
        ;;
    
    "setup")
        echo "⚙️  Running setup script..."
        ./Scripts/setup.sh
        ;;
    
    "test-api")
        echo "🧪 Testing Groq API connection..."
        read -s -p "Enter API key: " api_key
        echo ""
        
        response=$(curl -s -w "%{http_code}" -o /tmp/groq_test.json \
            -H "Authorization: Bearer $api_key" \
            -H "Content-Type: application/json" \
            -d '{
                "model": "llama-3.3-70b-versatile",
                "messages": [{"role": "user", "content": "Fix this text: hello wrold"}],
                "max_tokens": 50
            }' \
            https://api.groq.com/openai/v1/chat/completions)
        
        if [ "$response" = "200" ]; then
            echo "✅ API test successful!"
            echo "Response:"
            cat /tmp/groq_test.json | python3 -m json.tool
        else
            echo "❌ API test failed (HTTP $response)"
            cat /tmp/groq_test.json
        fi
        rm -f /tmp/groq_test.json
        ;;
    
    "permissions")
        echo "🔓 Checking accessibility permissions..."
        osascript -e 'tell application "System Events" to get UI elements of process "Finder"' >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "✅ Accessibility permissions granted"
        else
            echo "❌ Accessibility permissions required"
            echo "   Opening System Preferences..."
            open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        fi
        ;;
    
    "logs")
        echo "📋 Showing Grammar Fixer logs..."
        log show --predicate 'subsystem contains "com.grammarfixer.app"' --last 1h
        ;;
    
    "reset")
        echo "🔄 Resetting Grammar Fixer data..."
        defaults delete com.grammarfixer.app 2>/dev/null || true
        security delete-generic-password -a "groq_api_key" -s "com.grammarfixer.app" 2>/dev/null || true
        echo "✅ Reset complete"
        ;;
    
    "dev")
        echo "🚀 Development mode: Build and Run..."
        pkill -f "grammar-fixer" 2>/dev/null || true
        ./Scripts/dev.sh build
        ./Scripts/dev.sh run
        ;;
    
    *)
        echo "Grammar Fixer Development Helper"
        echo "================================"
        echo ""
        echo "Usage: ./Scripts/dev.sh [command]"
        echo ""
        echo "Commands:"
        echo "  clean       - Clean build artifacts"
        echo "  build       - Build the application (removes sandbox)"
        echo "  run         - Run the built application"
        echo "  dev         - Build and run in development mode"
        echo "  install     - Install to /Applications"
        echo "  setup       - Run interactive setup"
        echo "  test-api    - Test Groq API connection"
        echo "  permissions - Check accessibility permissions"
        echo "  logs        - Show application logs"
        echo "  reset       - Reset all app data"
        echo ""
        ;;
esac