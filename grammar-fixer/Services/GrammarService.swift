//
//  GrammarService.swift
//  grammar-fixer
//
//  Created by Assistant on 2024-12-19.
//

import Foundation
import SwiftUI
import Combine

class GrammarService: ObservableObject {
    static let shared = GrammarService()
    
    @Published var isProcessing = false
    @Published var lastError: String?
    @Published var apiStatus: APIStatus = .unknown
    
    private let groqService = GroqAPIService()
    private let localChecker = LocalSpellChecker()
    private let historyManager = CorrectionHistoryManager.shared
    
    enum APIStatus {
        case unknown
        case working
        case failed
        case noApiKey
    }
    
    private init() {
        checkAPIStatus()
    }
    
    func checkAPIStatus() {
        Task {
            if SettingsManager.shared.groqAPIKey.isEmpty {
                apiStatus = .noApiKey
            } else {
                let isWorking = await groqService.testConnection()
                apiStatus = isWorking ? .working : .failed
            }
        }
    }
    
    func correctText(_ text: String) async -> String {
        isProcessing = true
        lastError = nil
        
        defer {
            isProcessing = false
        }
        
        // Try Groq API first
        if !SettingsManager.shared.groqAPIKey.isEmpty {
            do {
                let correctedText = try await groqService.correctGrammar(text)
                apiStatus = .working
                
                // Save to history if text was changed
                DispatchQueue.main.async {
                    self.historyManager.addCorrection(original: text, corrected: correctedText, method: CorrectionEntry.CorrectionMethod.api)
                }
                
                return correctedText
            } catch {
                lastError = "API Error: \(error.localizedDescription)"
                apiStatus = .failed
                
                // Fallback to local checking
                NotificationManager.shared.showNotification(
                    title: "Using Local Spell Check",
                    body: "API unavailable, using local spell checker as fallback"
                )
            }
        }
        
        // Fallback to local spell checking
        let correctedText = localChecker.correctText(text)
        
        // Save to history if text was changed
        DispatchQueue.main.async {
            self.historyManager.addCorrection(original: text, corrected: correctedText, method: CorrectionEntry.CorrectionMethod.local)
        }
        
        return correctedText
    }
    
    func correctSelectedText() async {
        guard let selectedText = AccessibilityManager.shared.getSelectedText() else {
            NotificationManager.shared.showNotification(
                title: "No Text Selected",
                body: "Please select some text to correct"
            )
            return
        }
        
        let correctedText = await correctText(selectedText)
        
        if correctedText != selectedText {
            _ = AccessibilityManager.shared.replaceSelectedText(with: correctedText)
            NotificationManager.shared.showNotification(
                title: "Grammar Corrected",
                body: "Text has been improved and replaced"
            )
        } else {
            NotificationManager.shared.showNotification(
                title: "No Changes Needed",
                body: "The selected text looks good!"
            )
        }
    }
}