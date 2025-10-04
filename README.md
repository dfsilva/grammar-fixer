# Grammar Fixer

A powerful macOS menu bar application that provides AI-powered grammar correction with global keyboard shortcuts. Built with SwiftUI and powered by Groq's Llama 3.3 70B model.

![Grammar Fixer Menu Bar](https://img.shields.io/badge/macOS-Menu%20Bar%20App-blue)
![Swift](https://img.shields.io/badge/Swift-5.5+-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Native-green)
![AI Powered](https://img.shields.io/badge/AI-Groq%20Llama%203.3-purple)

## ✨ Features

### ✅ Implemented Features

- **🎯 Menu Bar Integration**: Clean, native macOS menu bar app
- **⌨️ Global Keyboard Shortcut**: Press `⌘+Shift+G` to correct selected text anywhere
- **📝 Text Selection Detection**: Automatically detects and captures selected text
- **🤖 Groq AI-Powered Correction**: Uses Llama 3.3 70B for advanced grammar correction
- **🔄 Local Spell Check Fallback**: Works offline when API is unavailable
- **↔️ Text Replacement**: Seamlessly replaces corrected text in any application
- **🔓 Accessibility Permissions**: Handles macOS accessibility permissions automatically
- **🔔 User Notifications**: Smart notifications for feedback and status updates
- **🎛️ Enable/Disable Toggle**: Easy on/off functionality
- **🔑 API Key Management**: Secure API key storage in macOS Keychain
- **⚙️ Interactive Setup Scripts**: Automated configuration and deployment
- **🛠️ Command-Line Tools**: Build, test, and deployment automation

### 🎨 User Interface

- **Modern SwiftUI Design**: Clean, native macOS appearance
- **Status Indicators**: Visual feedback for API status and app state
- **Manual Text Correction**: Direct text input and correction interface
- **Settings Panel**: Comprehensive configuration options
- **Real-time Status**: Live updates of API connectivity and permissions

## 🚀 Quick Start

### Prerequisites

- macOS 12.0+ (Monterey or later)
- Xcode 14.0+
- [Optional] Groq API key for AI-powered corrections

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/grammar-fixer.git
   cd grammar-fixer
   ```

2. **Run the interactive setup**:
   ```bash
   ./Scripts/setup.sh
   ```

3. **Build and install**:
   ```bash
   ./Scripts/build.sh
   ./Scripts/dev.sh install
   ```

4. **Launch the app** and look for the Grammar Fixer icon in your menu bar!

## 🔧 Configuration

### API Key Setup

1. Visit [console.groq.com](https://console.groq.com)
2. Create a free account
3. Generate an API key
4. Enter it in the app settings or during setup

### Accessibility Permissions

Grammar Fixer requires accessibility permissions to read and modify text in other applications:

1. Go to **System Preferences** → **Security & Privacy** → **Privacy** → **Accessibility**
2. Click the lock and enter your password
3. Add Grammar Fixer to the list and check the box

## 📖 Usage

### Global Shortcut

1. Select any text in any application
2. Press `⌘+Shift+G`
3. The text will be automatically corrected and replaced

### Menu Bar Interface

1. Click the Grammar Fixer icon in your menu bar
2. Paste text in the manual correction field
3. Click "Fix Grammar" to get corrected text
4. Copy the result or adjust settings

### Features Overview

- **🎯 Smart Detection**: Automatically detects selected text
- **🤖 AI Processing**: Uses advanced language models for correction
- **🔄 Fallback Mode**: Local spell checking when offline
- **🔐 Secure Storage**: API keys stored in macOS Keychain
- **📊 Status Monitoring**: Real-time API and permission status
- **🔔 Notifications**: Non-intrusive feedback system

## 🛠️ Development

### Quick Commands

```bash
# Development helper script
./Scripts/dev.sh [command]

# Available commands:
./Scripts/dev.sh clean       # Clean build artifacts
./Scripts/dev.sh build       # Build the application  
./Scripts/dev.sh run         # Run the application
./Scripts/dev.sh install     # Install to /Applications
./Scripts/dev.sh test-api    # Test Groq API connection
./Scripts/dev.sh permissions # Check accessibility permissions
./Scripts/dev.sh logs        # View application logs
./Scripts/dev.sh reset       # Reset all app data
```

### Project Structure

```
grammar-fixer/
├── grammar-fixer/
│   ├── grammar_fixerApp.swift      # Main app entry point
│   ├── ContentView.swift           # Main UI interface
│   ├── Services/                   # Core services
│   │   ├── GrammarService.swift    # Grammar correction logic
│   │   ├── GroqAPIService.swift    # Groq API integration
│   │   └── LocalSpellChecker.swift # Local fallback
│   ├── Managers/                   # System managers
│   │   ├── SettingsManager.swift   # App settings
│   │   ├── ShortcutManager.swift   # Global shortcuts
│   │   ├── AccessibilityManager.swift # Permissions
│   │   ├── TextSelectionManager.swift # Text handling
│   │   ├── NotificationManager.swift  # User feedback
│   │   └── KeychainManager.swift   # Secure storage
│   └── Assets.xcassets/            # App icons and assets
├── Scripts/                        # Build and deployment
│   ├── build.sh                    # Build automation
│   ├── setup.sh                    # Interactive setup
│   ├── dev.sh                      # Development helper
│   └── ExportOptions.plist         # Export configuration
└── README.md                       # This file
```

### Architecture

- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for state management
- **URLSession**: Network communication with Groq API
- **ApplicationServices**: Accessibility and text manipulation
- **Security**: Keychain integration for secure storage
- **UserNotifications**: System notifications
- **Carbon**: Low-level keyboard shortcut registration

## 🔌 API Integration

### Groq API

Grammar Fixer uses Groq's fast inference API with the Llama 3.3 70B model:

- **Endpoint**: `https://api.groq.com/openai/v1/chat/completions`
- **Model**: `llama-3.3-70b-versatile`
- **Features**: Grammar correction, style improvement, clarity enhancement
- **Fallback**: Local spell checking when API unavailable

### Local Processing

When the API is unavailable, Grammar Fixer falls back to:

- **NSSpellChecker**: macOS native spell checking
- **Pattern Matching**: Common grammar rule corrections
- **Text Normalization**: Spacing and punctuation fixes

## 🔒 Privacy & Security

- **Local Processing**: Text can be processed locally without API calls
- **Secure Storage**: API keys stored in macOS Keychain
- **No Data Collection**: No user data is collected or stored
- **Permission-Based**: Only accesses text when explicitly requested
- **Open Source**: Full source code available for audit

## 📋 Requirements

### System Requirements

- **macOS**: 12.0+ (Monterey or later)
- **Architecture**: Intel or Apple Silicon Macs
- **Memory**: 100MB RAM
- **Storage**: 50MB disk space
- **Permissions**: Accessibility access for text manipulation

### Development Requirements

- **Xcode**: 14.0+
- **Swift**: 5.5+
- **Command Line Tools**: Git, curl, bash
- **Optional**: create-dmg for distribution packages

## 🚧 Troubleshooting

### Common Issues

**Global shortcut not working:**
- Check accessibility permissions in System Preferences
- Ensure the app is enabled in the menu bar
- Restart the app if shortcuts stop responding

**API connection failed:**
- Verify your Groq API key is correct
- Check internet connectivity
- View logs with `./Scripts/dev.sh logs`

**Text replacement not working:**
- Grant accessibility permissions
- Try selecting text again before using the shortcut
- Check if the target app supports text replacement

**App not appearing in menu bar:**
- Check if the app is running in Activity Monitor
- Restart the app
- Verify installation in /Applications

### Debug Commands

```bash
# Check app status
ps aux | grep grammar-fixer

# View detailed logs
./Scripts/dev.sh logs

# Test API connectivity
./Scripts/dev.sh test-api

# Reset all settings
./Scripts/dev.sh reset
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Setup

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Groq**: For providing fast AI inference API
- **Apple**: For excellent development tools and frameworks
- **SwiftUI Community**: For inspiration and best practices
- **Open Source Community**: For making this project possible

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/grammar-fixer/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/grammar-fixer/discussions)
- **Email**: support@grammarfixer.app

---

**Grammar Fixer** - Making text perfect, one correction at a time! ✨