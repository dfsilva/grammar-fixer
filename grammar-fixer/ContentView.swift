//
//  ContentView.swift
//  grammar-fixer
//
//  Created by Diego Silva on 03/10/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var grammarService: GrammarService
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var shortcutManager: ShortcutManager
    
    @State private var inputText = ""
    @State private var correctedText = ""
    @State private var displayText = "No correction yet"
    @State private var showingApiKeyInput = false
    @State private var apiKeyInput = ""
    @State private var refreshTrigger = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: settingsManager.isEnabled ? "text.badge.checkmark" : "text.badge.xmark")
                    .foregroundColor(settingsManager.isEnabled ? .green : .red)
                Text("Grammar Fixer")
                    .font(.headline)
                Spacer()
                
                // Status indicator
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
            }
            
            // Enable/Disable toggle
            HStack {
                Toggle("Enable Grammar Fixer", isOn: $settingsManager.isEnabled)
                    .toggleStyle(.switch)
            }
            
            if settingsManager.isEnabled {
                Divider()
                
                // API Status
                HStack {
                    Text("API Status:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(apiStatusText)
                        .font(.caption)
                        .foregroundColor(apiStatusColor)
                    
                    Spacer()
                    
                    if grammarService.apiStatus == .noApiKey {
                        Button("Setup") {
                            showingApiKeyInput = true
                        }
                        .buttonStyle(.borderless)
                        .foregroundColor(.blue)
                    }
                }
                
                // Shortcut info
                HStack {
                    Text("Shortcut:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("⌘+Shift+G")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    Image(systemName: shortcutManager.isRegistered ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .foregroundColor(shortcutManager.isRegistered ? .green : .orange)
                        .font(.caption)
                }
                
                Divider()
                
                // Manual text correction
                VStack(alignment: .leading, spacing: 8) {
                    Text("Manual Text Correction:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $inputText)
                        .frame(height: 60)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                    
                    Button(action: correctManualText) {
                        Label("Correct Text", systemImage: "wand.and.stars.inverse")
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                }
                
                // Always show corrected text section, but hide when empty
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Corrected text:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button("Copy") {
                            print("📋 Copy button pressed. Text to copy: '\(correctedText)'")
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(correctedText, forType: .string)
                            print("📋 Text copied to clipboard")
                            // Show simple notification instead
                            print("📋 Text copied successfully")
                        }
                        .buttonStyle(.borderless)
                        .foregroundColor(.blue)
                        .disabled(correctedText.isEmpty)
                    }
                    
                    ScrollView {
                        Text(displayText)
                            .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
                            .padding(8)
                            .background(displayText == "No correction yet" ? Color.secondary.opacity(0.05) : Color.green.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(displayText == "No correction yet" ? Color.clear : Color.green.opacity(0.6), lineWidth: 1)
                            )
                            .cornerRadius(6)
                            .foregroundColor(displayText == "No correction yet" ? .secondary : .primary)
                            .font(.system(size: 13, weight: displayText == "No correction yet" ? .medium : .semibold))
                            .id("display-text-\(refreshTrigger)")
                            .onAppear {
                                print("📱 UI Text onAppear - displayText: '\(displayText)', correctedText: '\(correctedText)'")
                            }
                            .onChange(of: displayText) { _, newValue in
                                print("📱 UI Text onChange - displayText changed to: '\(newValue)'")
                            }
                    }
                    .frame(minHeight: 80, maxHeight: 80)
                    .id("scroll-container-\(refreshTrigger)")
                }
                .opacity(displayText == "No correction yet" ? 0.6 : 1.0)
                .id("corrected-section-\(refreshTrigger)")
                .onAppear {
                    print("📺 Corrected text UI appeared with text: '\(correctedText)', displayText: '\(displayText)'")
                }
                .onChange(of: correctedText) { oldValue, newValue in
                    print("📺 Corrected text changed from '\(oldValue)' to '\(newValue)'")
                    print("📺 Force UI refresh with trigger: \(refreshTrigger)")
                }
                .onChange(of: displayText) { oldValue, newValue in
                    print("📺 Display text changed from '\(oldValue)' to '\(newValue)'")
                }
                
                if let error = grammarService.lastError {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Divider()
                
                // Quick actions
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Button("Settings") {
                            openSettingsWindow()
                        }
                        .frame(maxWidth: .infinity)
                        
                        Button("Check Permissions") {
                            if AccessibilityManager.shared.hasPermissions() {
                                NotificationManager.shared.showBanner(
                                    title: "Permissions OK",
                                    message: "All required permissions granted"
                                )
                            } else {
                                AccessibilityManager.shared.requestPermissions()
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            
            Divider()
            
            // Footer
            HStack {
                Button("About") {
                    showAbout()
                }
                .buttonStyle(.borderless)
                
                Spacer()
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.borderless)
                .foregroundColor(.red)
            }
        }
        .padding()
        .frame(width: 350)
        .sheet(isPresented: $showingApiKeyInput) {
            ApiKeyInputView(
                apiKey: $apiKeyInput,
                onSave: { key in
                    DispatchQueue.main.async {
                        settingsManager.setAPIKey(key)
                        showingApiKeyInput = false
                    }
                },
                onDismiss: {
                    showingApiKeyInput = false
                }
            )
        }
        .onAppear {
            apiKeyInput = settingsManager.groqAPIKey
            grammarService.checkAPIStatus()
        }
    }
    
    private var statusColor: Color {
        if !settingsManager.isEnabled {
            return .red
        }
        switch grammarService.apiStatus {
        case .working:
            return .green
        case .failed, .noApiKey:
            return .orange
        case .unknown:
            return .gray
        }
    }
    
    private var apiStatusText: String {
        switch grammarService.apiStatus {
        case .working:
            return "Connected"
        case .failed:
            return "Failed"
        case .noApiKey:
            return "No API Key"
        case .unknown:
            return "Checking..."
        }
    }
    
    private var apiStatusColor: Color {
        switch grammarService.apiStatus {
        case .working:
            return .green
        case .failed, .noApiKey:
            return .orange
        case .unknown:
            return .gray
        }
    }
    
    private func correctManualText() {
        Task {
            print("🔧 Starting manual text correction for: '\(inputText)'")
            let result = await grammarService.correctText(inputText)
            print("🔧 Received result: '\(result)'")
            
            await MainActor.run {
                // Set both the corrected text and display text
                correctedText = result
                displayText = result.isEmpty ? "No correction yet" : result
                refreshTrigger += 1
                print("🔧 Set correctedText to: '\(correctedText)', isEmpty: \(correctedText.isEmpty)")
                print("🔧 Set displayText to: '\(displayText)'")
                print("🔧 refreshTrigger: \(refreshTrigger)")
            }
        }
    }
    

    
    private func openSettingsWindow() {
        let settingsView = SettingsView()
            .environmentObject(settingsManager)
            .environmentObject(grammarService)
        
        let hostingController = NSHostingController(rootView: settingsView)
        let window = NSWindow(contentViewController: hostingController)
        
        window.title = "Settings"
        window.setContentSize(NSSize(width: 450, height: 400))
        window.styleMask = [NSWindow.StyleMask.titled, NSWindow.StyleMask.closable]
        window.isReleasedWhenClosed = false
        window.center()
        window.makeKeyAndOrderFront(window)
        
        // Keep window alive
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "Grammar Fixer"
        alert.informativeText = """
        A powerful grammar correction tool powered by Groq AI.
        
        Features:
        • Global shortcut (⌘+Shift+G)
        • AI-powered grammar correction
        • Local spell checking fallback
        • Menu bar integration
        
        Version 1.0
        """
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var grammarService: GrammarService
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.title2)
                .fontWeight(.bold)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                Toggle("Use local fallback when API fails", isOn: $settingsManager.useLocalFallback)
                Toggle("Show notifications", isOn: $settingsManager.showNotifications)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Groq API Key")
                    .font(.headline)
                
                SecureField("Enter your Groq API key", text: $settingsManager.groqAPIKey)
                    .textFieldStyle(.roundedBorder)
                
                Text("Get your free API key from console.groq.com")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button(action: {
                    print("Test Connection button tapped")
                    settingsManager.checkAPIStatus()
                }) {
                    Text("Test Connection")
                        .frame(minWidth: 120)
                }
                .disabled(settingsManager.groqAPIKey.isEmpty)
                .buttonStyle(.bordered)
                .controlSize(.regular)
                
                // Show API status feedback
                Text("Status: \(settingsManager.apiStatus == .checking ? "Testing..." : settingsManager.apiStatus == .available ? "✅ Connected" : settingsManager.apiStatus == .error ? "❌ Failed" : "Not configured")")
                    .font(.caption)
                    .foregroundColor(settingsManager.apiStatus == .available ? .green : settingsManager.apiStatus == .error ? .red : settingsManager.apiStatus == .checking ? .orange : .secondary)
            }
            
            Divider()
            
            HStack {
                Button(action: {
                    print("Reset Settings button tapped")
                    settingsManager.reset()
                }) {
                    Text("Reset Settings")
                        .frame(minWidth: 100)
                }
                .foregroundColor(.red)
                .buttonStyle(.bordered)
                .controlSize(.regular)
                
                Spacer()
                
                Button(action: {
                    print("Done button tapped")
                    // Explicitly save settings by triggering UserDefaults synchronization
                    UserDefaults.standard.synchronize()
                    
                    // If there's an API key, ensure it's properly set
                    if !settingsManager.groqAPIKey.isEmpty {
                        settingsManager.setAPIKey(settingsManager.groqAPIKey)
                    }
                    
                    dismiss()
                }) {
                    Text("Done")
                        .frame(minWidth: 80)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
            }
        }
        .padding()
        .frame(width: 450, height: 400)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
    }
}

struct ApiKeyInputView: View {
    @Binding var apiKey: String
    let onSave: (String) -> Void
    let onDismiss: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Setup Groq API Key")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("To use AI-powered grammar correction, you need a free Groq API key.")
                .foregroundColor(.secondary)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("1. Visit console.groq.com")
                Text("2. Create a free account")
                Text("3. Generate an API key")
                Text("4. Paste it below:")
            }
            .font(.caption)
            
            SecureField("Paste your API key here", text: $apiKey)
                .textFieldStyle(.roundedBorder)
            
            HStack {
                Button("Skip for Now") {
                    onDismiss()
                }
                
                Spacer()
                
                Button("Save") {
                    if !apiKey.isEmpty {
                        onSave(apiKey)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(apiKey.isEmpty)
            }
        }
        .padding()
        .frame(width: 400, height: 250)
    }
}

#Preview {
    ContentView()
        .environmentObject(GrammarService.shared)
        .environmentObject(SettingsManager.shared)
        .environmentObject(ShortcutManager.shared)
}
