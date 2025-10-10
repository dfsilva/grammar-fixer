//
//  GeminiAPIService.swift
//  grammar-fixer
//
//  Created by Assistant on 2025-10-09.
//

import Foundation

class GeminiAPIService {
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro:generateContent"

    func testConnection() async -> Bool {
        do {
            _ = try await makeTestRequest()
            return true
        } catch {
            return false
        }
    }

    func correctGrammar(_ text: String) async throws -> String {
        let prompt = """
        You are a grammar and writing assistant. Your task is to correct grammar, spelling, punctuation, and improve clarity while preserving the original meaning and tone.

        Rules:
        - Fix grammatical errors
        - Correct spelling mistakes
        - Improve punctuation
        - Enhance clarity and readability
        - Preserve the original tone and style
        - Keep technical terms and proper nouns intact
        - Return ONLY the corrected text, no explanations

        Text to correct:
        \(text)
        """

        return try await makeRequest(prompt: prompt)
    }

    func correctGrammarAndMakePolite(_ text: String) async throws -> String {
        let prompt = """
        You are a professional communication assistant. Your task is to:
        1. Correct all grammar, spelling, and punctuation errors
        2. Make the message more polite, professional, and friendly
        3. Add appropriate courteous language while maintaining the core message

        Rules:
        - Fix all grammatical errors
        - Correct spelling mistakes
        - Improve punctuation
        - Make the tone more polite and respectful
        - Add polite phrases like "please", "thank you", "I would appreciate", "if possible", etc. where appropriate
        - Keep the message professional but warm
        - Preserve the original intent and key information
        - Keep technical terms and proper nouns intact
        - Return ONLY the improved text, no explanations

        Text to improve:
        \(text)
        """

        return try await makeRequest(prompt: prompt)
    }

    private func makeTestRequest() async throws -> String {
        let apiKey = SettingsManager.shared.geminiAPIKey
        guard !apiKey.isEmpty else {
            throw APIError.noAPIKey
        }

        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        [
                            "text": "Test connection. Just respond with 'OK'."
                        ]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 1.0,
                "maxOutputTokens": 100
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(httpResponse.statusCode)
        }

        let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        guard let candidates = jsonResponse?["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            throw APIError.invalidResponse
        }

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func makeRequest(prompt: String) async throws -> String {
        let apiKey = SettingsManager.shared.geminiAPIKey
        guard !apiKey.isEmpty else {
            throw APIError.noAPIKey
        }

        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        [
                            "text": prompt
                        ]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.1,
                "maxOutputTokens": 1000
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(httpResponse.statusCode)
        }

        let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        guard let candidates = jsonResponse?["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            throw APIError.invalidResponse
        }

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
