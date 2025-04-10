import Foundation
import SwiftUI

class SimpleAuthService: ObservableObject {
    static let shared = SimpleAuthService()
    
    @Published var isAuthenticated = false
    @Published var currentUser: UserData?
    @Published var isLoading = false
    @Published var error: String?
    
    private let userDataKey = "user_data"
    
    // URL for auth endpoints
//    private let baseURL = "http://3.99.223.30/api/auth"
    private let baseURL = "http://localhost:3000/api/auth"
    
    private init() {
        // Try to load saved user data
        loadSavedUser()
    }
    
    // MARK: - Authentication Methods
    
    func register(name: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        error = nil
        
        guard let url = URL(string: "\(baseURL)/register") else {
            handleError("Invalid URL")
            completion(false)
            return
        }
        
        let registerData = ["name": name, "email": email, "password": password]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: registerData)
        } catch {
            handleError("Failed to encode registration data")
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.handleError("Network error: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.handleError("Invalid response")
                    completion(false)
                    return
                }
                
                guard let data = data else {
                    self.handleError("No data received")
                    completion(false)
                    return
                }
                
                // Handle error responses
                if httpResponse.statusCode >= 400 {
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let message = json["message"] as? String {
                        self.handleError(message)
                    } else {
                        self.handleError("Registration failed: \(httpResponse.statusCode)")
                    }
                    completion(false)
                    return
                }
                
                // Process successful registration
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let userData = json["user"] as? [String: Any] {
                        
                        let user = UserData(
                            id: userData["_id"] as? String ?? "",
                            name: userData["name"] as? String ?? "",
                            email: userData["email"] as? String ?? "",
                            createdAt: userData["createdAt"] as? String
                        )
                        
                        self.handleSuccessfulAuth(user)
                        completion(true)
                    } else {
                        self.handleError("Invalid user data format")
                        completion(false)
                    }
                } catch {
                    self.handleError("Failed to decode response: \(error.localizedDescription)")
                    completion(false)
                }
            }
        }.resume()
    }
    
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        error = nil
        
        guard let url = URL(string: "\(baseURL)/login") else {
            handleError("Invalid URL")
            completion(false)
            return
        }
        
        let loginData = ["email": email, "password": password]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: loginData)
        } catch {
            handleError("Failed to encode login data")
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.handleError("Network error: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.handleError("Invalid response")
                    completion(false)
                    return
                }
                
                guard let data = data else {
                    self.handleError("No data received")
                    completion(false)
                    return
                }
                
                // Handle error responses
                if httpResponse.statusCode >= 400 {
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let message = json["message"] as? String {
                        self.handleError(message)
                    } else {
                        self.handleError("Login failed: \(httpResponse.statusCode)")
                    }
                    completion(false)
                    return
                }
                
                // Process successful login
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let userData = json["user"] as? [String: Any] {
                        
                        let user = UserData(
                            id: userData["_id"] as? String ?? "",
                            name: userData["name"] as? String ?? "",
                            email: userData["email"] as? String ?? "",
                            createdAt: userData["createdAt"] as? String
                        )
                        
                        self.handleSuccessfulAuth(user)
                        completion(true)
                    } else {
                        self.handleError("Invalid user data format")
                        completion(false)
                    }
                } catch {
                    self.handleError("Failed to decode response: \(error.localizedDescription)")
                    completion(false)
                }
            }
        }.resume()
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: userDataKey)
        
        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.currentUser = nil
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleSuccessfulAuth(_ user: UserData) {
        // Save user data
        saveUserData(user)
        
        // Update state
        self.isAuthenticated = true
        self.currentUser = user
    }
    
    private func saveUserData(_ user: UserData) {
        // Convert user to dictionary for storage
        let userData: [String: Any] = [
            "id": user.id,
            "name": user.name,
            "email": user.email,
            "createdAt": user.createdAt ?? ""
        ]
        
        // Save to UserDefaults
        UserDefaults.standard.set(userData, forKey: userDataKey)
    }
    
    private func loadSavedUser() {
        // Load user data from UserDefaults
        if let userData = UserDefaults.standard.dictionary(forKey: userDataKey) {
            let user = UserData(
                id: userData["id"] as? String ?? "",
                name: userData["name"] as? String ?? "",
                email: userData["email"] as? String ?? "",
                createdAt: userData["createdAt"] as? String
            )
            
            self.currentUser = user
            self.isAuthenticated = true
        }
    }
    
    private func handleError(_ message: String) {
        self.error = message
        self.isLoading = false
        print("Auth Error: \(message)")
    }
}

// Simple user data model
struct UserData: Identifiable {
    let id: String
    let name: String
    let email: String
    let createdAt: String?
}
