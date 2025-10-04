//
//  ShortcutManager.swift
//  grammar-fixer
//
//  Created by Diego Silva on 03/10/25.
//

import Foundation
import Carbon
import Combine

class ShortcutManager: ObservableObject {
    static let shared = ShortcutManager()
    
    @Published var isRegistered: Bool = false
    
    private var hotKeyRef: EventHotKeyRef?
    private var hotKeyID = EventHotKeyID(signature: 0x47464958, id: 1) // 'GFIX'
    
    private init() {}
    
    func registerGlobalShortcut() {
        unregisterGlobalShortcut() // Clean up any existing registration
        
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))
        
        InstallEventHandler(
            GetApplicationEventTarget(),
            { (nextHandler, theEvent, userData) -> OSStatus in
                ShortcutManager.shared.handleHotKeyEvent()
                return noErr
            },
            1,
            &eventType,
            nil,
            nil
        )
        
        let keyCode: UInt32 = 5 // G key
        let modifiers: UInt32 = UInt32(cmdKey | shiftKey)
        
        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        if status != noErr {
            print("Failed to register global shortcut: \(status)")
            isRegistered = false
        } else {
            print("Global shortcut registered successfully (⌘+Shift+G)")
            isRegistered = true
        }
    }
    
    func unregisterGlobalShortcut() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
            isRegistered = false
        }
    }
    
    private func handleHotKeyEvent() {
        print("🔥 Shortcut triggered (⌘+Shift+G)")
        
        guard SettingsManager.shared.isEnabled else {
            print("❌ Grammar Fixer is disabled")
            return
        }
        
        print("✅ Grammar Fixer is enabled, checking accessibility permissions...")
        guard AccessibilityManager.shared.hasPermissions() else {
            print("❌ No accessibility permissions")
            NotificationManager.shared.showNotification(
                title: "Grammar Fixer",
                body: "Accessibility permissions required. Please grant access in System Preferences."
            )
            return
        }
        
        print("✅ Accessibility permissions granted, getting selected text...")
        if let selectedText = AccessibilityManager.shared.getSelectedText(), !selectedText.isEmpty {
            print("✅ Selected text found: '\(selectedText)'")
            TextSelectionManager.shared.processSelectedText(selectedText)
        } else {
            print("❌ No text selected or empty text")
            NotificationManager.shared.showNotification(
                title: "Grammar Fixer",
                body: "No text selected. Please select some text first."
            )
        }
    }
}