//
//  GroqAPIService.swift
//  grammar-fixer
//
//  Created by Diego Silva on 03/10/25.
//

import Foundation

class GroqAPIService {
    private let baseURL = "https://api.groq.com/openai/v1/chat/completions"
    private let model = "openai/gpt-oss-120b" // Using a valid Groq model
    
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
        """

        return try await makeRequest(prompt: prompt, text: text)
    }

    func correctGrammarAndMakePolite(_ text: String) async throws -> String {
        let prompt = """
        You are a professional communication assistant. Your task is to:
        1. Correct all grammar, spelling, and punctuation errors
        2. Make the message slightly more polite and professional
        3. Improve the tone while keeping it natural and concise

        Rules:
        - Fix all grammatical errors
        - Correct spelling mistakes
        - Improve punctuation
        - Make the tone moderately more polite and respectful, but keep it natural
        - Add "please" or "thank you" ONLY when it naturally fits the context
        - DON'T make it overly formal or verbose
        - DON'T add excessive courteous phrases
        - Keep the message concise and direct
        - Preserve the original intent and key information
        - Keep technical terms and proper nouns intact
        - Maintain a balance between politeness and directness
        - Avoid phrases like "I would appreciate", "if possible", "when you get a chance" unless they were in the original
        - Return ONLY the improved text, no explanations

        Text to improve:
        """

        return try await makeRequest(prompt: prompt, text: text)
    }

    func translateToPortuguese(_ text: String) async throws -> String {
        let prompt = """
        You are a professional translator. Your task is to translate the given text to Brazilian Portuguese (pt-BR).

        Rules:
        - Translate to natural Brazilian Portuguese
        - Use Brazilian Portuguese expressions and vocabulary (not European Portuguese)
        - Maintain the original tone and style
        - Keep the same level of formality
        - Preserve technical terms when appropriate, but explain them if needed
        - Keep proper nouns unchanged
        - Ensure the translation sounds natural to native Brazilian speakers
        - Return ONLY the translated text, no explanations

        Text to translate:
        """

        return try await makeRequest(prompt: prompt, text: text)
    }

    func translateToEnglish(_ text: String) async throws -> String {
        let prompt = """
        You are a professional translator. Your task is to translate the given text to English (en-US).

        Rules:
        - Translate to natural, fluent English
        - Use American English spelling and expressions
        - Maintain the original tone and style
        - Keep the same level of formality
        - Preserve technical terms when appropriate
        - Keep proper nouns unchanged
        - Ensure the translation sounds natural to native English speakers
        - If the text is already in English, improve grammar and clarity
        - Return ONLY the translated text, no explanations

        Text to translate:
        """

        return try await makeRequest(prompt: prompt, text: text)
    }
    
    private func makeTestRequest() async throws -> String {
        guard let url = URL(string: baseURL) else {
            throw APIError.invalidURL
        }
        
        let apiKey = SettingsManager.shared.groqAPIKey
        guard !apiKey.isEmpty else {
            throw APIError.noAPIKey
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": model,
            "messages": [
                [
                    "role": "user",
                    "content": "Test connection. Just respond with 'OK'."
                ]
            ],
            "temperature": 1.0,
            "max_completion_tokens": 100,
            "top_p": 1.0,
            "stream": false
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
        
        guard let choices = jsonResponse?["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw APIError.invalidResponse
        }
        
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func makeRequest(prompt: String, text: String) async throws -> String {
        guard let url = URL(string: baseURL) else {
            throw APIError.invalidURL
        }
        
        let apiKey = SettingsManager.shared.groqAPIKey
        guard !apiKey.isEmpty else {
            throw APIError.noAPIKey
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": model,
            "messages": [
                [
                    "role": "system",
                    "content": prompt
                ],
                [
                    "role": "user",
                    "content": text
                ]
            ],
            "temperature": 0.1,
            "max_completion_tokens": 1000,
            "top_p": 1.0,
            "stream": false
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
        
        guard let choices = jsonResponse?["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw APIError.invalidResponse
        }
        
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum APIError: LocalizedError {
    case invalidURL
    case noAPIKey
    case invalidResponse
    case httpError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .noAPIKey:
            return "No API key configured"
        case .invalidResponse:
            return "Invalid API response format"
        case .httpError(let code):
            return "HTTP error: \(code)"
        }
    }
}
