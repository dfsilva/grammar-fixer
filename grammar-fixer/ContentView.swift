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
    @State private var showingHistory = false
    @State private var selectedMode: CorrectionMode = .grammarOnly
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header Section
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: settingsManager.isEnabled ? "text.badge.checkmark" : "text.badge.xmark")
                        .font(.title2)
                        .foregroundColor(settingsManager.isEnabled ? .green : .gray)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(settingsManager.isEnabled ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Grammar Fixer")
                            .font(.system(size: 16, weight: .semibold))

                        HStack(spacing: 6) {
                            Circle()
                                .fill(statusColor)
                                .frame(width: 6, height: 6)

                            Text(apiStatusText)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    // Enable/Disable toggle
                    Toggle("", isOn: $settingsManager.isEnabled)
                        .toggleStyle(.switch)
                        .labelsHidden()
                }
            }
            .padding(16)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
            
            if settingsManager.isEnabled {
                // Info Cards Section
                VStack(spacing: 12) {
                    // API Status Card
                    HStack(spacing: 10) {
                        Image(systemName: grammarService.apiStatus == .working ? "checkmark.circle.fill" : grammarService.apiStatus == .noApiKey ? "key.slash.fill" : "exclamationmark.triangle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(apiStatusColor)
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("API Status")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                            Text(apiStatusText)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(apiStatusColor)
                        }

                        Spacer()

                        if grammarService.apiStatus == .noApiKey {
                            Button(action: { showingApiKeyInput = true }) {
                                Text("Setup")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.blue)
                                    .cornerRadius(6)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    .padding(12)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)

                    // Shortcuts Card
                    VStack(spacing: 10) {
                        HStack(spacing: 10) {
                            Image(systemName: "command")
                                .font(.system(size: 18))
                                .foregroundColor(.blue)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Grammar Fix")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                                Text("⌘ + Shift + G")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.primary)
                            }

                            Spacer()

                            Image(systemName: shortcutManager.isRegistered ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .foregroundColor(shortcutManager.isRegistered ? .green : .orange)
                                .font(.system(size: 16))
                        }

                        Divider()

                        HStack(spacing: 10) {
                            Image(systemName: "sparkle")
                                .font(.system(size: 18))
                                .foregroundColor(.purple)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Polite Mode")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                                Text("⌘ + Shift + F")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.primary)
                            }

                            Spacer()

                            Image(systemName: shortcutManager.isRegistered ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .foregroundColor(shortcutManager.isRegistered ? .green : .orange)
                                .font(.system(size: 16))
                        }

                        Divider()

                        HStack(spacing: 10) {
                            Image(systemName: "globe")
                                .font(.system(size: 18))
                                .foregroundColor(.orange)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Translate to PT-BR")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                                Text("⌘ + Shift + P")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.primary)
                            }

                            Spacer()

                            Image(systemName: shortcutManager.isRegistered ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .foregroundColor(shortcutManager.isRegistered ? .green : .orange)
                                .font(.system(size: 16))
                        }

                        Divider()

                        HStack(spacing: 10) {
                            Image(systemName: "globe.americas.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.green)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Translate to English")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                                Text("⌘ + Shift + E")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.primary)
                            }

                            Spacer()

                            Image(systemName: shortcutManager.isRegistered ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .foregroundColor(shortcutManager.isRegistered ? .green : .orange)
                                .font(.system(size: 16))
                        }
                    }
                    .padding(12)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                }
                .padding(16)

                Divider()
                
                // Manual Correction Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Manual Correction")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.primary)

                        Spacer()

                        // Mode selector
                        HStack(spacing: 6) {
                            Button(action: {
                                selectedMode = .grammarOnly
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "text.badge.checkmark")
                                        .font(.system(size: 10))
                                    Text("Grammar")
                                        .font(.system(size: 10, weight: .medium))
                                }
                                .foregroundColor(selectedMode == .grammarOnly ? .white : .secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(selectedMode == .grammarOnly ? Color.blue : Color(NSColor.controlBackgroundColor))
                                .cornerRadius(6)
                            }
                            .buttonStyle(.borderless)

                            Button(action: {
                                selectedMode = .polite
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "sparkle")
                                        .font(.system(size: 10))
                                    Text("Polite")
                                        .font(.system(size: 10, weight: .medium))
                                }
                                .foregroundColor(selectedMode == .polite ? .white : .secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(selectedMode == .polite ? Color.purple : Color(NSColor.controlBackgroundColor))
                                .cornerRadius(6)
                            }
                            .buttonStyle(.borderless)

                            Button(action: {
                                selectedMode = .translateToPortuguese
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "globe")
                                        .font(.system(size: 10))
                                    Text("PT-BR")
                                        .font(.system(size: 10, weight: .medium))
                                }
                                .foregroundColor(selectedMode == .translateToPortuguese ? .white : .secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(selectedMode == .translateToPortuguese ? Color.orange : Color(NSColor.controlBackgroundColor))
                                .cornerRadius(6)
                            }
                            .buttonStyle(.borderless)

                            Button(action: {
                                selectedMode = .translateToEnglish
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "globe.americas.fill")
                                        .font(.system(size: 10))
                                    Text("EN")
                                        .font(.system(size: 10, weight: .medium))
                                }
                                .foregroundColor(selectedMode == .translateToEnglish ? .white : .secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(selectedMode == .translateToEnglish ? Color.green : Color(NSColor.controlBackgroundColor))
                                .cornerRadius(6)
                            }
                            .buttonStyle(.borderless)
                        }
                    }

                    // Input area
                    VStack(alignment: .leading, spacing: 6) {
                        Text(selectedMode == .translateToPortuguese || selectedMode == .translateToEnglish ? "Enter text to translate:" : selectedMode == .polite ? "Enter text to make polite:" : "Enter text to correct:")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)

                        ZStack(alignment: .topLeading) {
                            if inputText.isEmpty {
                                Text("Type or paste your text here...")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary.opacity(0.5))
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 8)
                            }

                            TextEditor(text: $inputText)
                                .font(.system(size: 13))
                                .scrollContentBackground(.hidden)
                                .frame(height: 70)
                                .padding(4)
                        }
                        .background(Color(NSColor.textBackgroundColor))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                        .cornerRadius(6)
                    }

                    // Action buttons
                    HStack(spacing: 10) {
                        Button(action: correctManualText) {
                            HStack(spacing: 6) {
                                Image(systemName: selectedMode == .translateToPortuguese ? "globe" : selectedMode == .translateToEnglish ? "globe.americas.fill" : selectedMode == .polite ? "sparkle" : "sparkles")
                                    .font(.system(size: 12))
                                Text(selectedMode == .translateToPortuguese || selectedMode == .translateToEnglish ? "Translate" : selectedMode == .polite ? "Make Polite" : "Fix Grammar")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(
                                    colors: selectedMode == .translateToPortuguese ? [Color.orange, Color.orange.opacity(0.8)] : selectedMode == .translateToEnglish ? [Color.green, Color.green.opacity(0.8)] : selectedMode == .polite ? [Color.purple, Color.purple.opacity(0.8)] : [Color.blue, Color.blue.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(8)
                        }
                        .buttonStyle(.borderless)
                        .disabled(inputText.isEmpty)

                        Button(action: clearText) {
                            HStack(spacing: 6) {
                                Image(systemName: "trash")
                                    .font(.system(size: 12))
                                Text("Clear")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(8)
                        }
                        .buttonStyle(.borderless)
                        .disabled(inputText.isEmpty && correctedText.isEmpty)
                    }
                }
                .padding(16)
                
                // Results Section
                if displayText != "No correction yet" || grammarService.lastError != nil {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Result")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.primary)

                            Spacer()

                            if !correctedText.isEmpty {
                                Button(action: {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(correctedText, forType: .string)
                                    NotificationManager.shared.showNotification(title: "Copied", body: "Text copied to clipboard")
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "doc.on.doc")
                                            .font(.system(size: 11))
                                        Text("Copy")
                                            .font(.system(size: 11, weight: .medium))
                                    }
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(6)
                                }
                                .buttonStyle(.borderless)
                            }
                        }

                        if let error = grammarService.lastError {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.orange)

                                Text(error)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                        } else {
                            ScrollView {
                                Text(displayText)
                                    .font(.system(size: 13))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(10)
                                    .id("display-text-\(refreshTrigger)")
                            }
                            .frame(height: 80)
                            .background(Color.green.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                            )
                            .cornerRadius(8)
                            .id("scroll-container-\(refreshTrigger)")
                        }
                    }
                    .padding(16)
                    .id("corrected-section-\(refreshTrigger)")
                }

                Divider()
                
                // Quick Actions
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        Button(action: openSettingsWindow) {
                            HStack(spacing: 6) {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 13))
                                Text("Settings")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(8)
                        }
                        .buttonStyle(.borderless)

                        Button(action: { showingHistory = true }) {
                            HStack(spacing: 6) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.system(size: 13))
                                Text("History")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(8)
                        }
                        .buttonStyle(.borderless)
                    }

                    Button(action: {
                        if AccessibilityManager.shared.hasPermissions() {
                            NotificationManager.shared.showNotification(
                                title: "✅ Permissions Granted",
                                body: "All accessibility permissions are properly configured"
                            )
                        } else {
                            // Request permissions (shows system dialog first time)
                            AccessibilityManager.shared.requestPermissions()

                            // Also open System Settings after a brief delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                AccessibilityManager.shared.openAccessibilitySettings()

                                NotificationManager.shared.showNotification(
                                    title: "⚠️ Permissions Required",
                                    body: "Opening System Settings. Please enable Grammar Fixer in Accessibility, then restart the app."
                                )
                            }
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "lock.shield")
                                .font(.system(size: 13))
                            Text("Check Permissions")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.borderless)
                }
                .padding(16)
            }

            // Footer
            VStack(spacing: 0) {
                Divider()

                HStack(spacing: 16) {
                    Button(action: showAbout) {
                        HStack(spacing: 4) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 12))
                            Text("About")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(.secondary)
                    }
                    .buttonStyle(.borderless)

                    Spacer()

                    Text("v1.0")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary.opacity(0.6))

                    Spacer()

                    Button(action: { NSApplication.shared.terminate(nil) }) {
                        HStack(spacing: 4) {
                            Image(systemName: "power")
                                .font(.system(size: 12))
                            Text("Quit")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(.red)
                    }
                    .buttonStyle(.borderless)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
            }
        }
        .frame(width: 380)
        .sheet(isPresented: $showingApiKeyInput) {
            ApiKeyInputView(
                apiKey: $apiKeyInput,
                onSave: { key in
                    DispatchQueue.main.async {
                        settingsManager.setAPIKey(key, for: settingsManager.selectedProvider)
                        showingApiKeyInput = false
                    }
                },
                onDismiss: {
                    showingApiKeyInput = false
                }
            )
            .environmentObject(settingsManager)
        }
        .sheet(isPresented: $showingHistory) {
            CorrectionHistoryView()
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
    
    private func clearText() {
        inputText = ""
        correctedText = ""
        displayText = "No correction yet"
        refreshTrigger += 1
    }
    
    private func correctManualText() {
        Task {
            let result = await grammarService.correctText(inputText, mode: selectedMode)

            await MainActor.run {
                // Set both the corrected text and display text
                correctedText = result
                displayText = result.isEmpty ? "No correction yet" : result
                refreshTrigger += 1
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
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Settings")
                        .font(.system(size: 18, weight: .semibold))

                    Text("Configure Grammar Fixer")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding(20)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // General Settings Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("General")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)

                        VStack(spacing: 10) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Local Fallback")
                                        .font(.system(size: 13, weight: .medium))
                                    Text("Use local spell checker when API fails")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Toggle("", isOn: $settingsManager.useLocalFallback)
                                    .labelsHidden()
                            }
                            .padding(12)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(8)

                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Notifications")
                                        .font(.system(size: 13, weight: .medium))
                                    Text("Show system notifications for corrections")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Toggle("", isOn: $settingsManager.showNotifications)
                                    .labelsHidden()
                            }
                            .padding(12)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(8)
                        }
                    }

                    // AI Provider Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("AI Provider")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)

                        HStack(spacing: 10) {
                            ForEach(AIProvider.allCases, id: \.self) { provider in
                                Button(action: {
                                    settingsManager.selectedProvider = provider
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: provider.iconName)
                                            .font(.system(size: 14))
                                        Text(provider.displayName)
                                            .font(.system(size: 13, weight: .medium))
                                    }
                                    .foregroundColor(settingsManager.selectedProvider == provider ? .white : .primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        settingsManager.selectedProvider == provider ?
                                        LinearGradient(
                                            colors: [Color.blue, Color.blue.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ) : LinearGradient(
                                            colors: [Color(NSColor.controlBackgroundColor), Color(NSColor.controlBackgroundColor)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(settingsManager.selectedProvider == provider ? Color.clear : Color.secondary.opacity(0.2), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                    }

                    // API Key Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("API Configuration")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)

                            Spacer()

                            // Status indicator
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(settingsManager.apiStatus == .available ? Color.green : settingsManager.apiStatus == .error ? Color.red : Color.orange)
                                    .frame(width: 8, height: 8)

                                Text(settingsManager.apiStatus == .checking ? "Checking..." : settingsManager.apiStatus == .available ? "Connected" : settingsManager.apiStatus == .error ? "Failed" : "Not configured")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(settingsManager.selectedProvider.displayName) API Key")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)

                            if settingsManager.selectedProvider == .groq {
                                SecureField("Enter your Groq API key", text: $settingsManager.groqAPIKey)
                                    .textFieldStyle(.plain)
                                    .font(.system(size: 13))
                                    .padding(10)
                                    .background(Color(NSColor.textBackgroundColor))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                                    )
                                    .cornerRadius(8)

                                HStack(spacing: 8) {
                                    Image(systemName: "info.circle")
                                        .font(.system(size: 11))
                                        .foregroundColor(.blue)

                                    Text("Get your free API key from")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)

                                    Button(action: {
                                        if let url = URL(string: "https://console.groq.com") {
                                            NSWorkspace.shared.open(url)
                                        }
                                    }) {
                                        Text("console.groq.com")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(.blue)
                                    }
                                    .buttonStyle(.borderless)
                                }
                            } else {
                                SecureField("Enter your Gemini API key", text: $settingsManager.geminiAPIKey)
                                    .textFieldStyle(.plain)
                                    .font(.system(size: 13))
                                    .padding(10)
                                    .background(Color(NSColor.textBackgroundColor))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                                    )
                                    .cornerRadius(8)

                                HStack(spacing: 8) {
                                    Image(systemName: "info.circle")
                                        .font(.system(size: 11))
                                        .foregroundColor(.blue)

                                    Text("Get your free API key from")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)

                                    Button(action: {
                                        if let url = URL(string: "https://aistudio.google.com/app/apikey") {
                                            NSWorkspace.shared.open(url)
                                        }
                                    }) {
                                        Text("Google AI Studio")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(.blue)
                                    }
                                    .buttonStyle(.borderless)
                                }
                            }

                            Button(action: {
                                settingsManager.checkAPIStatus()
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle")
                                        .font(.system(size: 12))
                                    Text("Test Connection")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(
                                    LinearGradient(
                                        colors: [Color.blue, Color.blue.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(8)
                            }
                            .buttonStyle(.borderless)
                            .disabled(settingsManager.currentAPIKey.isEmpty)
                            .opacity(settingsManager.currentAPIKey.isEmpty ? 0.5 : 1.0)
                        }
                        .padding(12)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                    }
                }
                .padding(20)
            }

            // Footer
            VStack(spacing: 0) {
                Divider()

                HStack(spacing: 12) {
                    Button(action: {
                        settingsManager.reset()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 11))
                            Text("Reset")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(.red)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.borderless)

                    Spacer()

                    Button(action: {
                        UserDefaults.standard.synchronize()

                        // Save the current provider's API key
                        if !settingsManager.currentAPIKey.isEmpty {
                            settingsManager.setAPIKey(settingsManager.currentAPIKey, for: settingsManager.selectedProvider)
                        }

                        dismiss()
                    }) {
                        Text("Done")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                            .frame(minWidth: 80)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.borderless)
                }
                .padding(16)
                .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
            }
        }
        .frame(width: 500, height: 480)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct ApiKeyInputView: View {
    @Binding var apiKey: String
    let onSave: (String) -> Void
    let onDismiss: () -> Void
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settingsManager: SettingsManager

    var providerName: String {
        settingsManager.selectedProvider.displayName
    }

    var providerURL: String {
        switch settingsManager.selectedProvider {
        case .groq:
            return "console.groq.com"
        case .gemini:
            return "aistudio.google.com/app/apikey"
        }
    }

    var providerFullURL: String {
        switch settingsManager.selectedProvider {
        case .groq:
            return "https://console.groq.com"
        case .gemini:
            return "https://aistudio.google.com/app/apikey"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: "key.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Setup API Key")
                        .font(.system(size: 18, weight: .semibold))

                    Text("Connect to \(providerName)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding(20)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))

            Divider()

            VStack(alignment: .leading, spacing: 20) {
                // Info section
                VStack(alignment: .leading, spacing: 12) {
                    Text("To use AI-powered grammar correction, you need a free \(providerName) API key.")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Text("1")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                                .background(Color.blue)
                                .cornerRadius(10)

                            Button(action: {
                                if let url = URL(string: providerFullURL) {
                                    NSWorkspace.shared.open(url)
                                }
                            }) {
                                Text("Visit \(providerURL)")
                                    .font(.system(size: 12))
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(.borderless)
                        }

                        HStack(spacing: 8) {
                            Text("2")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                                .background(Color.blue)
                                .cornerRadius(10)

                            Text("Create a free account")
                                .font(.system(size: 12))
                        }

                        HStack(spacing: 8) {
                            Text("3")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                                .background(Color.blue)
                                .cornerRadius(10)

                            Text("Generate an API key")
                                .font(.system(size: 12))
                        }

                        HStack(spacing: 8) {
                            Text("4")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                                .background(Color.blue)
                                .cornerRadius(10)

                            Text("Paste it below")
                                .font(.system(size: 12))
                        }
                    }
                }

                // Input section
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(providerName) API Key")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)

                    SecureField("Paste your \(providerName) API key here", text: $apiKey)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13))
                        .padding(10)
                        .background(Color(NSColor.textBackgroundColor))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                        .cornerRadius(8)
                }
            }
            .padding(20)

            Spacer()

            // Footer
            VStack(spacing: 0) {
                Divider()

                HStack(spacing: 12) {
                    Button(action: {
                        onDismiss()
                    }) {
                        Text("Skip for Now")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.borderless)

                    Spacer()

                    Button(action: {
                        if !apiKey.isEmpty {
                            onSave(apiKey)
                        }
                    }) {
                        Text("Save & Continue")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                            .frame(minWidth: 120)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.blue.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(8)
                    }
                    .buttonStyle(.borderless)
                    .disabled(apiKey.isEmpty)
                    .opacity(apiKey.isEmpty ? 0.5 : 1.0)
                }
                .padding(16)
                .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
            }
        }
        .frame(width: 450, height: 380)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

#Preview {
    ContentView()
        .environmentObject(GrammarService.shared)
        .environmentObject(SettingsManager.shared)
        .environmentObject(ShortcutManager.shared)
}
