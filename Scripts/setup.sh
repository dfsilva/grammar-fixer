#!/bin/bash

# Grammar Fixer Setup Script
# This script helps users set up Grammar Fixer with all necessary configurations

set -e

echo "🎯 Grammar Fixer Setup"
echo "======================"
echo ""

# Check if app is running
APP_RUNNING=$(pgrep -f "grammar-fixer" || echo "")
if [ ! -z "$APP_RUNNING" ]; then
    echo "⚠️  Grammar Fixer is currently running. Please quit the app first."
    exit 1
fi

# Function to get API key
setup_api_key() {
    echo "🔑 Setting up Groq API Key"
    echo "--------------------------"
    echo ""
    echo "To use AI-powered grammar correction, you need a Groq API key."
    echo "1. Visit https://console.groq.com"
    echo "2. Create a free account"
    echo "3. Navigate to API Keys section"
    echo "4. Create a new API key"
    echo ""
    
    read -p "Do you have a Groq API key? (y/n): " has_key
    
    if [[ $has_key =~ ^[Yy]$ ]]; then
        echo ""
        read -s -p "Please paste your API key: " api_key
        echo ""
        
        if [ ${#api_key} -lt 10 ]; then
            echo "❌ API key seems too short. Please try again."
            return 1
        fi
        
        # Test the API key
        echo "🧪 Testing API key..."
        
        response=$(curl -s -w "%{http_code}" -o /dev/null \
            -H "Authorization: Bearer $api_key" \
            -H "Content-Type: application/json" \
            -d '{
                "model": "llama-3.3-70b-versatile",
                "messages": [{"role": "user", "content": "test"}],
                "max_tokens": 10
            }' \
            https://api.groq.com/openai/v1/chat/completions)
        
        if [ "$response" = "200" ]; then
            echo "✅ API key is valid!"
            
            # Store in keychain (if available)
            if command -v security >/dev/null 2>&1; then
                security add-generic-password -a "groq_api_key" -s "com.grammarfixer.app" -w "$api_key" -U
                echo "🔐 API key saved securely in Keychain"
            else
                echo "⚠️  Keychain not available. You'll need to enter the API key in the app."
            fi
        else
            echo "❌ API key test failed. Please check your key and try again."
            return 1
        fi
    else
        echo ""
        echo "📝 No problem! You can:"
        echo "   • Use local spell checking (works without API key)"
        echo "   • Add API key later in the app settings"
        echo "   • Visit console.groq.com to get a free API key"
    fi
}

# Function to setup accessibility permissions
setup_accessibility() {
    echo ""
    echo "🔓 Setting up Accessibility Permissions"
    echo "---------------------------------------"
    echo ""
    echo "Grammar Fixer needs accessibility permissions to:"
    echo "• Read selected text from any application"
    echo "• Replace text with corrected versions"
    echo ""
    
    read -p "Open System Preferences to grant permissions? (y/n): " open_prefs
    
    if [[ $open_prefs =~ ^[Yy]$ ]]; then
        echo "🔧 Opening System Preferences..."
        open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        echo ""
        echo "📋 In System Preferences:"
        echo "1. Click the lock icon and enter your password"
        echo "2. Find 'Grammar Fixer' in the list"
        echo "3. Check the box next to it"
        echo "4. If Grammar Fixer isn't listed, click '+' and add it"
        echo ""
        read -p "Press Enter when you've granted permissions..."
    fi
}

# Function to setup launch at login
setup_launch_at_login() {
    echo ""
    echo "🚀 Launch at Login Setup"
    echo "------------------------"
    echo ""
    echo "Would you like Grammar Fixer to start automatically when you log in?"
    read -p "(y/n): " launch_at_login
    
    if [[ $launch_at_login =~ ^[Yy]$ ]]; then
        # Create launch agent plist
        PLIST_PATH="$HOME/Library/LaunchAgents/com.grammarfixer.app.plist"
        APP_PATH="/Applications/grammar-fixer.app"
        
        if [ ! -f "$APP_PATH/Contents/MacOS/grammar-fixer" ]; then
            echo "⚠️  App not found at $APP_PATH"
            echo "   Please install Grammar Fixer to /Applications first"
            return 1
        fi
        
        cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.grammarfixer.app</string>
    <key>ProgramArguments</key>
    <array>
        <string>$APP_PATH/Contents/MacOS/grammar-fixer</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF
        
        # Load the launch agent
        launchctl load "$PLIST_PATH"
        echo "✅ Grammar Fixer will now start at login"
    fi
}

# Function to verify installation
verify_installation() {
    echo ""
    echo "🔍 Verifying Installation"
    echo "------------------------"
    echo ""
    
    APP_PATH="/Applications/grammar-fixer.app"
    
    if [ -f "$APP_PATH/Contents/MacOS/grammar-fixer" ]; then
        echo "✅ App installed correctly"
        
        # Get version info
        VERSION=$(plutil -p "$APP_PATH/Contents/Info.plist" | grep CFBundleShortVersionString | cut -d'"' -f4 2>/dev/null || echo "Unknown")
        echo "📱 Version: $VERSION"
    else
        echo "❌ App not found at $APP_PATH"
        echo "   Please drag Grammar Fixer.app to /Applications"
        return 1
    fi
}

# Main setup flow
echo "This script will help you set up Grammar Fixer with all necessary configurations."
echo ""

# API Key setup
setup_api_key

# Accessibility permissions
setup_accessibility

# Launch at login
setup_launch_at_login

# Verify installation
verify_installation

echo ""
echo "🎉 Setup Complete!"
echo "=================="
echo ""
echo "Grammar Fixer is now ready to use!"
echo ""
echo "💡 Usage:"
echo "   • Look for the Grammar Fixer icon in your menu bar"
echo "   • Select text in any app and press ⌘+Shift+G to correct it"
echo "   • Click the menu bar icon for manual text correction"
echo ""
echo "🔧 If you need help:"
echo "   • Check the app's settings for configuration options"
echo "   • Ensure accessibility permissions are granted"
echo "   • Visit the project repository for support"
echo ""

read -p "Press Enter to exit..."