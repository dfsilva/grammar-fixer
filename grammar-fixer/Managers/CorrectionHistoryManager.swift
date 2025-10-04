//
//  CorrectionHistoryManager.swift
//  grammar-fixer
//
//  Created by Assistant on 2025-10-04.
//

import Foundation
import SwiftUI
import Combine

struct CorrectionEntry: Identifiable, Codable {
    let id: UUID
    let originalText: String
    let correctedText: String
    let timestamp: Date
    let method: CorrectionMethod
    
    enum CorrectionMethod: String, Codable, CaseIterable {
        case api = "API"
        case local = "Local"
        
        var displayName: String {
            return self.rawValue
        }
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}

class CorrectionHistoryManager: ObservableObject {
    static let shared = CorrectionHistoryManager()
    
    @Published var corrections: [CorrectionEntry] = []
    private let maxHistoryCount = 20
    private let userDefaults = UserDefaults.standard
    private let historyKey = "correction_history"
    
    private init() {
        loadHistory()
    }
    
    func addCorrection(original: String, corrected: String, method: CorrectionEntry.CorrectionMethod) {
        // Don't save if text wasn't actually corrected
        guard original != corrected else { return }
        
        let entry = CorrectionEntry(
            id: UUID(),
            originalText: original,
            correctedText: corrected,
            timestamp: Date(),
            method: method
        )
        
        // Add to beginning of array
        corrections.insert(entry, at: 0)
        
        // Keep only the last 20 corrections
        if corrections.count > maxHistoryCount {
            corrections = Array(corrections.prefix(maxHistoryCount))
        }
        
        saveHistory()
    }
    
    func clearHistory() {
        corrections.removeAll()
        saveHistory()
    }
    
    private func saveHistory() {
        do {
            let data = try JSONEncoder().encode(corrections)
            userDefaults.set(data, forKey: historyKey)
        } catch {
            // Handle encoding error silently
        }
    }
    
    private func loadHistory() {
        guard let data = userDefaults.data(forKey: historyKey) else { return }
        
        do {
            corrections = try JSONDecoder().decode([CorrectionEntry].self, from: data)
        } catch {
            // Handle decoding error silently, start with empty history
            corrections = []
        }
    }
}