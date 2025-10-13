//
//  TextSelectionManager.swift
//  grammar-fixer
//
//  Created by Diego Silva on 03/10/25.
//

import Foundation

class TextSelectionManager {
    static let shared = TextSelectionManager()

    private init() {}

    func processSelectedText(_ text: String, mode: CorrectionMode = .grammarOnly) {
        Task {
            let correctedText = await GrammarService.shared.correctText(text, mode: mode)

            DispatchQueue.main.async {
                if AccessibilityManager.shared.replaceSelectedText(with: correctedText) {
                    let title: String
                    let body: String

                    switch mode {
                    case .polite:
                        title = "Text Polished"
                        body = "Text has been corrected and made more polite."
                    case .translateToPortuguese:
                        title = "Translated to Portuguese"
                        body = "Text has been translated to Brazilian Portuguese."
                    case .translateToEnglish:
                        title = "Translated to English"
                        body = "Text has been translated to English."
                    case .grammarOnly:
                        title = "Grammar Corrected"
                        body = "Text has been corrected successfully."
                    }

                    NotificationManager.shared.showNotification(
                        title: title,
                        body: body
                    )
                } else {
                    NotificationManager.shared.showNotification(
                        title: "Grammar Fixer Error",
                        body: "Failed to replace text. Please check accessibility permissions."
                    )
                }
            }
        }
    }

    func manualCorrection(_ text: String, mode: CorrectionMode = .grammarOnly, completion: @escaping (String?, Error?) -> Void) {
        Task {
            let correctedText = await GrammarService.shared.correctText(text, mode: mode)
            completion(correctedText, nil)
        }
    }
}