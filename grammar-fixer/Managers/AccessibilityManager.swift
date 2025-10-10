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
        
        return isProcessTrusted
    }
    
    func requestAccessibilityPermission() {
        let trusted = AXIsProcessTrustedWithOptions([
            kAXTrustedCheckOptionPrompt.takeRetainedValue(): true
        ] as CFDictionary)
        
        if !trusted {
            // Permission dialog will be shown automatically
        }
    }
    
    func requestPermissions() {
        requestAccessibilityPermission()
    }

    func hasPermissions() -> Bool {
        return checkAccessibilityPermission()
    }

    func openAccessibilitySettings() {
        // Open System Settings to Accessibility preferences
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
    
    func getSelectedText() -> String? {
        guard checkAccessibilityPermission() else {
            return nil
        }
        
        // Add a small delay to ensure UI is ready
        Thread.sleep(forTimeInterval: 0.1)
        
        // Try the direct approach first
        if let text = getSelectedTextDirect() {
            return text
        }
        
        // Fallback: try using copy-paste approach
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
            // Try alternative approach: get focused application first
            var focusedAppRef: AnyObject?
            let appResult = AXUIElementCopyAttributeValue(
                systemWideElement,
                kAXFocusedApplicationAttribute as CFString,
                &focusedAppRef
            )
            
            if appResult == .success, let appRef = focusedAppRef {
                let focusedApp = appRef as! AXUIElement
                
                // Try to get focused element from the application
                var appFocusedElementRef: AnyObject?
                let appElementResult = AXUIElementCopyAttributeValue(
                    focusedApp,
                    kAXFocusedUIElementAttribute as CFString,
                    &appFocusedElementRef
                )
                
                if appElementResult == .success, let appElementRef = appFocusedElementRef {
                    let focusedElement = appElementRef as! AXUIElement
                    return getTextFromElement(focusedElement)
                }
            }
            
            return nil
        }
        
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
        
        if textResult == .success, let text = selectedText as? String, !text.isEmpty {
            return text
        }
        
        // If no selected text, try to get all text and find selection
        var allText: AnyObject?
        let allTextResult = AXUIElementCopyAttributeValue(
            element,
            kAXValueAttribute as CFString,
            &allText
        )
        
        if allTextResult == .success, let text = allText as? String {
            
            // Try to get selected range
            var selectedRange: AnyObject?
            let rangeResult = AXUIElementCopyAttributeValue(
                element,
                kAXSelectedTextRangeAttribute as CFString,
                &selectedRange
            )
            
            if rangeResult == .success, let range = selectedRange {
                
                // Extract text from range
                let rangeValue = range as! AXValue
                var cfRange = CFRange()
                if AXValueGetValue(rangeValue, .cfRange, &cfRange) {
                    let nsRange = NSRange(location: cfRange.location, length: cfRange.length)
                    let nsText = text as NSString
                    if nsRange.location + nsRange.length <= nsText.length && nsRange.length > 0 {
                        let selectedPart = nsText.substring(with: nsRange)
                        return selectedPart
                    }
                }
            }
        }
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
            return text
        } else {
            return nil
        }
    }
    
    func replaceSelectedText(with newText: String) -> Bool {
        guard checkAccessibilityPermission() else {
            return false
        }
        
        // Try direct accessibility approach first
        if replaceSelectedTextDirect(with: newText) {
            return true
        }
        
        // Fallback to copy-paste approach
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
            return false
        }
        
        let focusedElement = elementRef as! AXUIElement
        
        let setResult = AXUIElementSetAttributeValue(
            focusedElement,
            kAXSelectedTextAttribute as CFString,
            newText as CFString
        )
        
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
        
        return true
    }
}