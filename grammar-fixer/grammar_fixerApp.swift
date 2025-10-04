//
//  grammar_fixerApp.swift
//  grammar-fixer
//
//  Created by Diego Silva on 03/10/25.
//

import SwiftUI
import Cocoa
import Carbon

@main
struct grammar_fixerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // Use shared instances
    private let grammarService = GrammarService.shared
    private let settingsManager = SettingsManager.shared
    private let shortcutManager = ShortcutManager.shared
    
    var body: some Scene {
        MenuBarExtra("Grammar Fixer", systemImage: settingsManager.isEnabled ? "text.badge.checkmark" : "text.badge.xmark") {
            ContentView()
                .environmentObject(grammarService)
                .environmentObject(settingsManager)
                .environmentObject(shortcutManager)
        }
        .menuBarExtraStyle(.window)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide the app from the dock
        NSApp.setActivationPolicy(.accessory)
        
        // Request accessibility permissions if needed
        AccessibilityManager.shared.requestPermissions()
        
        // Setup notification center
        NotificationManager.shared.setupNotifications()
        
        // Register global shortcut
        ShortcutManager.shared.registerGlobalShortcut()
    }
}
