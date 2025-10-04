//
//  SettingsManager.swift
//  grammar-fixer
//
//  Created by Diego Silva on 03/10/25.
//

import Foundation
import Combine

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
    
    public init() {
        loadSettings()
        checkAPIStatus()
    }
    
    private func loadSettings() {
        isEnabled = UserDefaults.standard.bool(forKey: "isEnabled")
        useLocalFallback = UserDefaults.standard.object(forKey: "useLocalFallback") as? Bool ?? true
        showNotifications = UserDefaults.standard.object(forKey: "showNotifications") as? Bool ?? true
        groqAPIKey = KeychainManager.shared.load(for: "groqAPIKey") ?? ""
    }
    
    func setAPIKey(_ key: String) {
        groqAPIKey = key
        checkAPIStatus()
    }
    
    func reset() {
        isEnabled = true
        useLocalFallback = true
        showNotifications = true
        groqAPIKey = ""
        apiStatus = .unavailable
    }
    
    func checkAPIStatus() {
        guard !groqAPIKey.isEmpty else {
            apiStatus = .unavailable
            return
        }
        
        apiStatus = .checking
        
        // Simple API validation
        Task {
            do {
                let url = URL(string: "https://api.groq.com/openai/v1/models")!
                var request = URLRequest(url: url)
                request.setValue("Bearer \(groqAPIKey)", forHTTPHeaderField: "Authorization")
                
                let (_, response) = try await URLSession.shared.data(for: request)
                
                DispatchQueue.main.async {
                    if let httpResponse = response as? HTTPURLResponse {
                        self.apiStatus = httpResponse.statusCode == 200 ? .available : .error
                    } else {
                        self.apiStatus = .error
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.apiStatus = .error
                }
            }
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
