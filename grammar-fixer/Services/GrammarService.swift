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
    private let geminiService = GeminiAPIService()
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
            let currentKey = SettingsManager.shared.currentAPIKey

            if currentKey.isEmpty {
                apiStatus = .noApiKey
            } else {
                let isWorking: Bool

                switch SettingsManager.shared.selectedProvider {
                case .groq:
                    isWorking = await groqService.testConnection()
                case .gemini:
                    isWorking = await geminiService.testConnection()
                }

                apiStatus = isWorking ? .working : .failed
            }
        }
    }

    func correctText(_ text: String, mode: CorrectionMode = .grammarOnly) async -> String {
        isProcessing = true
        lastError = nil

        defer {
            isProcessing = false
        }

        let currentKey = SettingsManager.shared.currentAPIKey

        // Try selected API provider first
        if !currentKey.isEmpty {
            do {
                let correctedText: String

                switch SettingsManager.shared.selectedProvider {
                case .groq:
                    if mode == .polite {
                        correctedText = try await groqService.correctGrammarAndMakePolite(text)
                    } else if mode == .translateToPortuguese {
                        correctedText = try await groqService.translateToPortuguese(text)
                    } else if mode == .translateToEnglish {
                        correctedText = try await groqService.translateToEnglish(text)
                    } else {
                        correctedText = try await groqService.correctGrammar(text)
                    }
                case .gemini:
                    if mode == .polite {
                        correctedText = try await geminiService.correctGrammarAndMakePolite(text)
                    } else if mode == .translateToPortuguese {
                        correctedText = try await geminiService.translateToPortuguese(text)
                    } else if mode == .translateToEnglish {
                        correctedText = try await geminiService.translateToEnglish(text)
                    } else {
                        correctedText = try await geminiService.correctGrammar(text)
                    }
                }

                apiStatus = .working

                // Save to history if text was changed
                DispatchQueue.main.async {
                    self.historyManager.addCorrection(original: text, corrected: correctedText, method: CorrectionEntry.CorrectionMethod.api)
                }

                return correctedText
            } catch {
                lastError = "API Error: \(error.localizedDescription)"
                apiStatus = .failed

                // Fallback to local checking (only for grammar mode)
                if mode == .grammarOnly {
                    NotificationManager.shared.showNotification(
                        title: "Using Local Spell Check",
                        body: "API unavailable, using local spell checker as fallback"
                    )
                } else {
                    let modeDescription = mode == .polite ? "Polite mode" : "Translation"
                    NotificationManager.shared.showNotification(
                        title: "API Unavailable",
                        body: "\(modeDescription) requires API access. Please check your connection."
                    )
                    return text // Return original text when API fails
                }
            }
        } else if mode != .grammarOnly {
            // Non-grammar modes require API
            let modeDescription = mode == .polite ? "Polite mode" : "Translation"
            NotificationManager.shared.showNotification(
                title: "API Key Required",
                body: "\(modeDescription) requires an API key. Please configure one in Settings."
            )
            return text
        }

        // Fallback to local spell checking (only for grammar mode)
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