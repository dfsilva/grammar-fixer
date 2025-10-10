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
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Correction History")
                        .font(.system(size: 18, weight: .semibold))

                    Text("\(historyManager.corrections.count) of 20 corrections")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Clear history button
                if !historyManager.corrections.isEmpty {
                    Button(action: {
                        historyManager.clearHistory()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "trash")
                                .font(.system(size: 12))
                            Text("Clear All")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.borderless)
                }
            }
            .padding(20)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))

            Divider()
            
            // History list
            if historyManager.corrections.isEmpty {
                VStack(spacing: 20) {
                    Spacer()

                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 56))
                        .foregroundColor(.secondary.opacity(0.5))

                    VStack(spacing: 8) {
                        Text("No corrections yet")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.secondary)

                        Text("Your correction history will appear here when you start using Grammar Fixer")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 300)
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(historyManager.corrections) { correction in
                            CorrectionHistoryRowView(correction: correction)
                        }
                    }
                    .padding(20)
                }
            }

            // Footer
            Divider()

            HStack {
                Spacer()

                Button(action: { dismiss() }) {
                    Text("Done")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                        .frame(minWidth: 80)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .buttonStyle(.borderless)
            }
            .padding(16)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
        }
        .frame(width: 650, height: 550)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct CorrectionHistoryRowView: View {
    let correction: CorrectionEntry
    @State private var showingFullTexts = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with timestamp and method
            HStack(spacing: 8) {
                // Method badge
                HStack(spacing: 6) {
                    Image(systemName: correction.method == .api ? "cloud.fill" : "laptopcomputer")
                        .font(.system(size: 11))
                    Text(correction.method.displayName)
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    LinearGradient(
                        colors: correction.method == .api ? [Color.blue, Color.blue.opacity(0.8)] : [Color.green, Color.green.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(6)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)

                    Text(correction.timeAgo)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            
            // Original text
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                        Text("Original")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button(action: {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(correction.originalText, forType: .string)
                    }) {
                        HStack(spacing: 3) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 10))
                            Text("Copy")
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                    }
                    .buttonStyle(.borderless)
                }

                Text(showingFullTexts ? correction.originalText : String(correction.originalText.prefix(120)) + (correction.originalText.count > 120 ? "..." : ""))
                    .font(.system(size: 12))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color.red.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.red.opacity(0.2), lineWidth: 1.5)
                    )
                    .cornerRadius(8)
            }

            // Corrected text
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                        Text("Corrected")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button(action: {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(correction.correctedText, forType: .string)
                    }) {
                        HStack(spacing: 3) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 10))
                            Text("Copy")
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                    }
                    .buttonStyle(.borderless)
                }

                Text(showingFullTexts ? correction.correctedText : String(correction.correctedText.prefix(120)) + (correction.correctedText.count > 120 ? "..." : ""))
                    .font(.system(size: 12))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color.green.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.green.opacity(0.2), lineWidth: 1.5)
                    )
                    .cornerRadius(8)
            }

            // Toggle full text button
            if correction.originalText.count > 120 || correction.correctedText.count > 120 {
                Button(action: { showingFullTexts.toggle() }) {
                    HStack(spacing: 4) {
                        Text(showingFullTexts ? "Show Less" : "Show More")
                            .font(.system(size: 11, weight: .medium))
                        Image(systemName: showingFullTexts ? "chevron.up" : "chevron.down")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(6)
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(14)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    CorrectionHistoryView()
}