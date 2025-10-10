//
//  SettingsManager.swift
//  grammar-fixer
//
//  Created by Diego Silva on 03/10/25.
//

import Foundation
import Combine

enum AIProvider: String, CaseIterable {
    case groq = "Groq"
    case gemini = "Google Gemini"

    var displayName: String {
        return self.rawValue
    }

    var iconName: String {
        switch self {
        case .groq:
            return "bolt.fill"
        case .gemini:
            return "sparkles"
        }
    }
}

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    @Published var isEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "isEnabled")
        }
    }

    @Published var useLocalFallback: Bool = true {
        didSet {
            UserDefaults.standard.set(useLocalFallback, forKey: "useLocalFallback")
        }
    }

    @Published var showNotifications: Bool = true {
        didSet {
            UserDefaults.standard.set(showNotifications, forKey: "showNotifications")
        }
    }

    @Published var selectedProvider: AIProvider = .groq {
        didSet {
            UserDefaults.standard.set(selectedProvider.rawValue, forKey: "selectedProvider")
            checkAPIStatus()
        }
    }

    @Published var apiStatus: APIStatus = .checking
    @Published var groqAPIKey: String = "" {
        didSet {
            if !groqAPIKey.isEmpty {
                KeychainManager.shared.save(groqAPIKey, for: "groqAPIKey")
            } else {
                KeychainManager.shared.delete(for: "groqAPIKey")
            }
        }
    }

    @Published var geminiAPIKey: String = "" {
        didSet {
            if !geminiAPIKey.isEmpty {
                KeychainManager.shared.save(geminiAPIKey, for: "geminiAPIKey")
            } else {
                KeychainManager.shared.delete(for: "geminiAPIKey")
            }
        }
    }
    
    public init() {
        loadSettings()
        checkAPIStatus()
    }

    private func loadSettings() {
        isEnabled = UserDefaults.standard.bool(forKey: "isEnabled")
        useLocalFallback = UserDefaults.standard.object(forKey: "useLocalFallback") as? Bool ?? true
        showNotifications = UserDefaults.standard.object(forKey: "showNotifications") as? Bool ?? true
        groqAPIKey = KeychainManager.shared.load(for: "groqAPIKey") ?? ""
        geminiAPIKey = KeychainManager.shared.load(for: "geminiAPIKey") ?? ""

        // Load selected provider
        if let providerString = UserDefaults.standard.string(forKey: "selectedProvider"),
           let provider = AIProvider(rawValue: providerString) {
            selectedProvider = provider
        }
    }

    func setAPIKey(_ key: String, for provider: AIProvider) {
        switch provider {
        case .groq:
            groqAPIKey = key
        case .gemini:
            geminiAPIKey = key
        }
        checkAPIStatus()
    }

    var currentAPIKey: String {
        switch selectedProvider {
        case .groq:
            return groqAPIKey
        case .gemini:
            return geminiAPIKey
        }
    }

    func reset() {
        isEnabled = true
        useLocalFallback = true
        showNotifications = true
        groqAPIKey = ""
        geminiAPIKey = ""
        selectedProvider = .groq
        apiStatus = .unavailable
    }

    func checkAPIStatus() {
        let currentKey = currentAPIKey

        guard !currentKey.isEmpty else {
            apiStatus = .unavailable
            return
        }

        apiStatus = .checking

        Task {
            let isWorking: Bool

            switch selectedProvider {
            case .groq:
                isWorking = await checkGroqAPI()
            case .gemini:
                isWorking = await checkGeminiAPI()
            }

            DispatchQueue.main.async {
                self.apiStatus = isWorking ? .available : .error
            }
        }
    }

    private func checkGroqAPI() async -> Bool {
        do {
            let url = URL(string: "https://api.groq.com/openai/v1/models")!
            var request = URLRequest(url: url)
            request.setValue("Bearer \(groqAPIKey)", forHTTPHeaderField: "Authorization")

            let (_, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
            return false
        } catch {
            return false
        }
    }

    private func checkGeminiAPI() async -> Bool {
        let baseURL = "https://generativelanguage.googleapis.com/v1beta/models?key=\(geminiAPIKey)"

        do {
            guard let url = URL(string: baseURL) else {
                return false
            }

            let (_, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
            return false
        } catch {
            return false
        }
    }
}

enum APIStatus {
    case checking
    case available
    case unavailable
    case error
    
    var displayText: String {
        switch self {
        case .checking:
            return "Checking..."
        case .available:
            return "Available"
        case .unavailable:
            return "No API Key"
        case .error:
            return "Error"
        }
    }
    
    var isWorking: Bool {
        return self == .available
    }
}
