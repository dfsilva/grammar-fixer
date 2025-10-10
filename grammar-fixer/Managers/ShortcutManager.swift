//
//  ShortcutManager.swift
//  grammar-fixer
//
//  Created by Diego Silva on 03/10/25.
//

import Foundation
import Carbon
import Combine

enum CorrectionMode {
    case grammarOnly
    case polite
}

class ShortcutManager: ObservableObject {
    static let shared = ShortcutManager()

    @Published var isRegistered: Bool = false

    private var grammarHotKeyRef: EventHotKeyRef?
    private var politeHotKeyRef: EventHotKeyRef?
    private var grammarHotKeyID = EventHotKeyID(signature: 0x47464958, id: 1) // 'GFIX'
    private var politeHotKeyID = EventHotKeyID(signature: 0x50464958, id: 2) // 'PFIX'

    private init() {}

    func registerGlobalShortcut() {
        unregisterGlobalShortcut() // Clean up any existing registration

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))

        InstallEventHandler(
            GetApplicationEventTarget(),
            { (nextHandler, theEvent, userData) -> OSStatus in
                var hotKeyID = EventHotKeyID()
                GetEventParameter(theEvent, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hotKeyID)

                if hotKeyID.id == 1 {
                    ShortcutManager.shared.handleHotKeyEvent(mode: .grammarOnly)
                } else if hotKeyID.id == 2 {
                    ShortcutManager.shared.handleHotKeyEvent(mode: .polite)
                }

                return noErr
            },
            1,
            &eventType,
            nil,
            nil
        )

        // Register Grammar shortcut (⌘+Shift+G)
        let grammarKeyCode: UInt32 = 5 // G key
        let grammarModifiers: UInt32 = UInt32(cmdKey | shiftKey)

        let grammarStatus = RegisterEventHotKey(
            grammarKeyCode,
            grammarModifiers,
            grammarHotKeyID,
            GetApplicationEventTarget(),
            0,
            &grammarHotKeyRef
        )

        // Register Polite shortcut (⌘+Shift+P)
        let politeKeyCode: UInt32 = 35 // P key
        let politeModifiers: UInt32 = UInt32(cmdKey | shiftKey)

        let politeStatus = RegisterEventHotKey(
            politeKeyCode,
            politeModifiers,
            politeHotKeyID,
            GetApplicationEventTarget(),
            0,
            &politeHotKeyRef
        )

        isRegistered = (grammarStatus == noErr && politeStatus == noErr)
    }

    func unregisterGlobalShortcut() {
        if let grammarHotKeyRef = grammarHotKeyRef {
            UnregisterEventHotKey(grammarHotKeyRef)
            self.grammarHotKeyRef = nil
        }

        if let politeHotKeyRef = politeHotKeyRef {
            UnregisterEventHotKey(politeHotKeyRef)
            self.politeHotKeyRef = nil
        }

        isRegistered = false
    }

    private func handleHotKeyEvent(mode: CorrectionMode) {
        guard SettingsManager.shared.isEnabled else {
            return
        }

        guard AccessibilityManager.shared.hasPermissions() else {
            NotificationManager.shared.showNotification(
                title: "Grammar Fixer",
                body: "Accessibility permissions required. Please grant access in System Preferences."
            )
            return
        }

        if let selectedText = AccessibilityManager.shared.getSelectedText(), !selectedText.isEmpty {
            TextSelectionManager.shared.processSelectedText(selectedText, mode: mode)
        } else {
            NotificationManager.shared.showNotification(
                title: "Grammar Fixer",
                body: "No text selected. Please select some text first."
            )
        }
    }
}