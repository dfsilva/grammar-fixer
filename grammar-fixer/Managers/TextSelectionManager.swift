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
    
    func processSelectedText(_ text: String) {
        Task {
            let correctedText = await GrammarService.shared.correctText(text)
            
            DispatchQueue.main.async {
                if AccessibilityManager.shared.replaceSelectedText(with: correctedText) {
                    NotificationManager.shared.showNotification(
                        title: "Grammar Corrected",
                        body: "Text has been corrected successfully."
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
    
    func manualCorrection(_ text: String, completion: @escaping (String?, Error?) -> Void) {
        Task {
            let correctedText = await GrammarService.shared.correctText(text)
            completion(correctedText, nil)
        }
    }
}