//
//  AccessibilityManager.swift
//  grammar-fixer
//
//  Created by Diego Silva on 03/10/25.
//

import Foundation
import ApplicationServices
import AppKit
import AppKit

class AccessibilityManager {
    static let shared = AccessibilityManager()
    
    private init() {}
    
    func checkAccessibilityPermission() -> Bool {
        let isProcessTrusted = AXIsProcessTrusted()
        print("🔐 AXIsProcessTrusted() result: \(isProcessTrusted)")
        
        // Get current app bundle path for debugging
        let bundlePath = Bundle.main.bundlePath
        print("🔐 App bundle path: \(bundlePath)")
        
        return isProcessTrusted
    }
    
    func requestAccessibilityPermission() {
        let trusted = AXIsProcessTrustedWithOptions([
            kAXTrustedCheckOptionPrompt.takeRetainedValue(): true
        ] as CFDictionary)
        
        if !trusted {
            print("Accessibility permission required. Please grant access in System Preferences.")
        }
    }
    
    func requestPermissions() {
        requestAccessibilityPermission()
    }
    
    func hasPermissions() -> Bool {
        return checkAccessibilityPermission()
    }
    
    func getSelectedText() -> String? {
        print("🔍 Getting selected text...")
        
        guard checkAccessibilityPermission() else {
            print("❌ No accessibility permission")
            return nil
        }
        
        print("✅ Accessibility permission granted")
        
        // Add a small delay to ensure UI is ready
        Thread.sleep(forTimeInterval: 0.1)
        
        // Try the direct approach first
        if let text = getSelectedTextDirect() {
            return text
        }
        
        // Fallback: try using copy-paste approach
        print("🔄 Trying copy-paste fallback...")
        return getSelectedTextViaCopy()
    }
    
    private func getSelectedTextDirect() -> String? {
        
        let systemWideElement = AXUIElementCreateSystemWide()
        var focusedElementRef: AnyObject?
        
        let result = AXUIElementCopyAttributeValue(
            systemWideElement,
            kAXFocusedUIElementAttribute as CFString,
            &focusedElementRef
        )
        
        guard result == .success, let elementRef = focusedElementRef else {
            print("❌ Failed to get focused element: \(result.rawValue)")
            
            // Try alternative approach: get focused application first
            print("🔄 Trying alternative approach: get focused application...")
            var focusedAppRef: AnyObject?
            let appResult = AXUIElementCopyAttributeValue(
                systemWideElement,
                kAXFocusedApplicationAttribute as CFString,
                &focusedAppRef
            )
            
            if appResult == .success, let appRef = focusedAppRef {
                print("✅ Got focused application")
                let focusedApp = appRef as! AXUIElement
                
                // Try to get focused element from the application
                var appFocusedElementRef: AnyObject?
                let appElementResult = AXUIElementCopyAttributeValue(
                    focusedApp,
                    kAXFocusedUIElementAttribute as CFString,
                    &appFocusedElementRef
                )
                
                if appElementResult == .success, let appElementRef = appFocusedElementRef {
                    print("✅ Got focused element from application")
                    let focusedElement = appElementRef as! AXUIElement
                    return getTextFromElement(focusedElement)
                } else {
                    print("❌ Failed to get focused element from application: \(appElementResult.rawValue)")
                }
            } else {
                print("❌ Failed to get focused application: \(appResult.rawValue)")
            }
            
            return nil
        }
        
        print("✅ Got focused element")
        
        let focusedElement = elementRef as! AXUIElement
        return getTextFromElement(focusedElement)
    }
    
    private func getTextFromElement(_ element: AXUIElement) -> String? {
        // First try to get selected text
        var selectedText: AnyObject?
        let textResult = AXUIElementCopyAttributeValue(
            element,
            kAXSelectedTextAttribute as CFString,
            &selectedText
        )
        
        print("📝 Text selection result: \(textResult.rawValue)")
        
        if textResult == .success, let text = selectedText as? String, !text.isEmpty {
            print("✅ Selected text retrieved: '\(text)'")
            return text
        }
        
        // If no selected text, try to get all text and find selection
        var allText: AnyObject?
        let allTextResult = AXUIElementCopyAttributeValue(
            element,
            kAXValueAttribute as CFString,
            &allText
        )
        
        print("📝 All text result: \(allTextResult.rawValue)")
        
        if allTextResult == .success, let text = allText as? String {
            print("✅ Found text value: '\(text.prefix(100))...' (truncated)")
            
            // Try to get selected range
            var selectedRange: AnyObject?
            let rangeResult = AXUIElementCopyAttributeValue(
                element,
                kAXSelectedTextRangeAttribute as CFString,
                &selectedRange
            )
            
            if rangeResult == .success, let range = selectedRange {
                print("✅ Got selected range: \(range)")
                
                // Extract text from range
                let rangeValue = range as! AXValue
                var cfRange = CFRange()
                if AXValueGetValue(rangeValue, .cfRange, &cfRange) {
                    let nsRange = NSRange(location: cfRange.location, length: cfRange.length)
                    let nsText = text as NSString
                    if nsRange.location + nsRange.length <= nsText.length && nsRange.length > 0 {
                        let selectedPart = nsText.substring(with: nsRange)
                        print("✅ Extracted selected text from range: '\(selectedPart)'")
                        return selectedPart
                    }
                }
            } else {
                print("❌ Failed to get selected range: \(rangeResult.rawValue)")
            }
        } else {
            print("❌ Failed to get text value: \(allTextResult.rawValue)")
        }
        
        print("❌ No selected text found")
        return nil
    }
    
    private func getSelectedTextViaCopy() -> String? {
        // Store current pasteboard content
        let pasteboard = NSPasteboard.general
        let originalContent = pasteboard.string(forType: .string)
        
        // Clear pasteboard
        pasteboard.clearContents()
        
        // Simulate Cmd+C to copy selected text
        let source = CGEventSource(stateID: .hidSystemState)
        
        // Press Cmd+C
        let keyDownEvent = CGEvent(keyboardEventSource: source, virtualKey: 8, keyDown: true) // 'c' key
        let keyUpEvent = CGEvent(keyboardEventSource: source, virtualKey: 8, keyDown: false)
        
        keyDownEvent?.flags = .maskCommand
        keyUpEvent?.flags = .maskCommand
        
        keyDownEvent?.post(tap: .cghidEventTap)
        keyUpEvent?.post(tap: .cghidEventTap)
        
        // Wait a bit for the copy operation
        Thread.sleep(forTimeInterval: 0.2)
        
        // Get the copied text
        let copiedText = pasteboard.string(forType: .string)
        
        // Restore original pasteboard content if we had any
        if let original = originalContent {
            pasteboard.clearContents()
            pasteboard.setString(original, forType: .string)
        }
        
        if let text = copiedText, !text.isEmpty, text != originalContent {
            print("✅ Got selected text via copy: '\(text)'")
            return text
        } else {
            print("❌ No text copied or same as original")
            return nil
        }
    }
    
    func replaceSelectedText(with newText: String) -> Bool {
        print("🔄 Replacing selected text with: '\(newText)'")
        
        guard checkAccessibilityPermission() else {
            print("❌ No accessibility permission for replacement")
            return false
        }
        
        // Try direct accessibility approach first
        if replaceSelectedTextDirect(with: newText) {
            print("✅ Text replaced via accessibility API")
            return true
        }
        
        // Fallback to copy-paste approach
        print("🔄 Trying copy-paste replacement fallback...")
        return replaceSelectedTextViaPaste(with: newText)
    }
    
    private func replaceSelectedTextDirect(with newText: String) -> Bool {
        let systemWideElement = AXUIElementCreateSystemWide()
        var focusedElementRef: AnyObject?
        
        let result = AXUIElementCopyAttributeValue(
            systemWideElement,
            kAXFocusedUIElementAttribute as CFString,
            &focusedElementRef
        )
        
        guard result == .success, let elementRef = focusedElementRef else {
            print("❌ Failed to get focused element for replacement: \(result.rawValue)")
            return false
        }
        
        let focusedElement = elementRef as! AXUIElement
        
        let setResult = AXUIElementSetAttributeValue(
            focusedElement,
            kAXSelectedTextAttribute as CFString,
            newText as CFString
        )
        
        print("📝 Direct replacement result: \(setResult.rawValue)")
        return setResult == .success
    }
    
    private func replaceSelectedTextViaPaste(with newText: String) -> Bool {
        // Store current pasteboard content
        let pasteboard = NSPasteboard.general
        let originalContent = pasteboard.string(forType: .string)
        
        // Put new text in pasteboard
        pasteboard.clearContents()
        pasteboard.setString(newText, forType: .string)
        
        // Simulate Cmd+V to paste the new text
        let source = CGEventSource(stateID: .hidSystemState)
        
        // Press Cmd+V
        let keyDownEvent = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: true) // 'v' key
        let keyUpEvent = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: false)
        
        keyDownEvent?.flags = .maskCommand
        keyUpEvent?.flags = .maskCommand
        
        keyDownEvent?.post(tap: .cghidEventTap)
        keyUpEvent?.post(tap: .cghidEventTap)
        
        // Wait a bit for the paste operation
        Thread.sleep(forTimeInterval: 0.1)
        
        // Restore original pasteboard content if we had any
        if let original = originalContent {
            pasteboard.clearContents()
            pasteboard.setString(original, forType: .string)
        } else {
            pasteboard.clearContents()
        }
        
        print("✅ Text replacement attempted via paste")
        return true
    }
}