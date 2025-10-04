//
//  LocalSpellChecker.swift
//  grammar-fixer
//
//  Created by Diego Silva on 03/10/25.
//

import Foundation
import AppKit

class LocalSpellChecker {
    private let spellChecker = NSSpellChecker.shared
    
    func correctText(_ text: String) -> String {
        var correctedText = text
        let range = NSRange(location: 0, length: text.utf16.count)
        
        // Find and correct misspelled words
        let misspelledRange = spellChecker.checkSpelling(of: text, startingAt: 0)
        
        if misspelledRange.location != NSNotFound {
            let misspelledWord = (text as NSString).substring(with: misspelledRange)
            let guesses = spellChecker.guesses(forWordRange: misspelledRange, in: text, language: nil, inSpellDocumentWithTag: 0)
            
            if let bestGuess = guesses?.first {
                correctedText = (text as NSString).replacingCharacters(in: misspelledRange, with: bestGuess)
            }
        }
        
        // Apply basic grammar rules
        correctedText = applyBasicGrammarRules(correctedText)
        
        return correctedText
    }
    
    private func applyBasicGrammarRules(_ text: String) -> String {
        var result = text
        
        // Capitalize first letter of sentences
        let sentencePattern = #"(^|[.!?]\s+)([a-z])"#
        result = result.replacingOccurrences(
            of: sentencePattern,
            with: "$1" + "$2".uppercased(),
            options: .regularExpression
        )
        
        // Fix common contractions
        let contractions = [
            "dont": "don't",
            "wont": "won't",
            "cant": "can't",
            "isnt": "isn't",
            "arent": "aren't",
            "wasnt": "wasn't",
            "werent": "weren't",
            "hasnt": "hasn't",
            "havent": "haven't",
            "hadnt": "hadn't",
            "shouldnt": "shouldn't",
            "wouldnt": "wouldn't",
            "couldnt": "couldn't",
            "mustnt": "mustn't",
            "neednt": "needn't",
            "shant": "shan't",
            "youre": "you're",
            "theyre": "they're",
            "were": "we're",
            "its": "it's",  // Context-dependent, but common mistake
            "im": "I'm",
            "ill": "I'll",
            "ive": "I've",
            "id": "I'd"
        ]
        
        for (incorrect, correct) in contractions {
            // Match whole words only
            let pattern = "\\b" + NSRegularExpression.escapedPattern(for: incorrect) + "\\b"
            result = result.replacingOccurrences(
                of: pattern,
                with: correct,
                options: [.regularExpression, .caseInsensitive]
            )
        }
        
        // Fix double spaces
        result = result.replacingOccurrences(of: "  +", with: " ", options: .regularExpression)
        
        // Fix spacing around punctuation
        result = result.replacingOccurrences(of: " +([,.!?;:])", with: "$1", options: .regularExpression)
        result = result.replacingOccurrences(of: "([.!?])([A-Z])", with: "$1 $2", options: .regularExpression)
        
        return result
    }
}