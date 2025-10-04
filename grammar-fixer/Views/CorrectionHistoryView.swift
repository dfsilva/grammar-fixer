//
//  CorrectionHistoryView.swift
//  grammar-fixer
//
//  Created by Assistant on 2025-10-04.
//

import SwiftUI

struct CorrectionHistoryView: View {
    @ObservedObject var historyManager = CorrectionHistoryManager.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Correction History")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("\(historyManager.corrections.count) of 20 corrections")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Clear history button
                if !historyManager.corrections.isEmpty {
                    Button("Clear All") {
                        historyManager.clearHistory()
                    }
                    .foregroundColor(.red)
                    .buttonStyle(.borderless)
                }
            }
            
            Divider()
            
            // History list
            if historyManager.corrections.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("No corrections yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Your correction history will appear here")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.secondary.opacity(0.05))
                .cornerRadius(8)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(historyManager.corrections) { correction in
                            CorrectionHistoryRowView(correction: correction)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            
            // Footer
            HStack {
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
            }
        }
        .padding()
        .frame(width: 600, height: 500)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct CorrectionHistoryRowView: View {
    let correction: CorrectionEntry
    @State private var showingFullTexts = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with timestamp and method
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(correction.timeAgo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Method badge
                Text(correction.method.displayName)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(correction.method == .api ? Color.blue.opacity(0.2) : Color.green.opacity(0.2))
                    .foregroundColor(correction.method == .api ? .blue : .green)
                    .cornerRadius(4)
            }
            
            // Original text
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Original:")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(action: {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(correction.originalText, forType: .string)
                    }) {
                        Image(systemName: "doc.on.doc")
                            .font(.caption)
                    }
                    .buttonStyle(.borderless)
                    .help("Copy original text")
                }
                
                Text(showingFullTexts ? correction.originalText : String(correction.originalText.prefix(100)) + (correction.originalText.count > 100 ? "..." : ""))
                    .font(.system(.body, design: .monospaced))
                    .padding(8)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
            }
            
            // Corrected text
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Corrected:")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(action: {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(correction.correctedText, forType: .string)
                    }) {
                        Image(systemName: "doc.on.doc")
                            .font(.caption)
                    }
                    .buttonStyle(.borderless)
                    .help("Copy corrected text")
                }
                
                Text(showingFullTexts ? correction.correctedText : String(correction.correctedText.prefix(100)) + (correction.correctedText.count > 100 ? "..." : ""))
                    .font(.system(.body, design: .monospaced))
                    .padding(8)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                    )
            }
            
            // Toggle full text button
            if correction.originalText.count > 100 || correction.correctedText.count > 100 {
                HStack {
                    Spacer()
                    
                    Button(showingFullTexts ? "Show Less" : "Show More") {
                        showingFullTexts.toggle()
                    }
                    .font(.caption)
                    .buttonStyle(.borderless)
                    .foregroundColor(.blue)
                }
            }
        }
        .padding(12)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    CorrectionHistoryView()
}