import Foundation

class APIService {
    static let shared = APIService()
    
    // Base URL of your Node.js API - update this when deploying
    let baseURL = "http://localhost:3000/api"
    
    private init() {}
    
    // MARK: - API Calls
    
    func fetchTasks(completion: @escaping ([Task]?, Error?) -> Void) {
        guard let userId = SimpleAuthService.shared.currentUser?.id else {
            completion(nil, NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"]))
            return
        }
        
        // Create URL with userId parameter
        guard var urlComponents = URLComponents(string: "\(baseURL)/tasks") else {
            completion(nil, NSError(domain: "InvalidURL", code: 0, userInfo: nil))
            return
        }
        
        // Add userId as query parameter
        urlComponents.queryItems = [URLQueryItem(name: "userId", value: userId)]
        
        guard let url = urlComponents.url else {
            completion(nil, NSError(domain: "InvalidURL", code: 0, userInfo: nil))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Status Code: \(httpResponse.statusCode)")
                
                // Handle unauthorized or user authentication errors
                if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                    DispatchQueue.main.async {
                        SimpleAuthService.shared.logout()
                    }
                    completion(nil, NSError(domain: "AuthError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Authentication error"]))
                    return
                }
            } else {
                print("❌ Not an HTTP response")
            }
            
            if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📦 Response Body:\n\(responseString)")
                } else {
                    print("⚠️ Unable to decode response data.")
                }
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...400).contains(httpResponse.statusCode) else {
                print("❌ Invalid response")
                completion(nil, NSError(domain: "APIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"]))
                return
            }
            
            if let data = data {
                do {
                    let tasks = try JSONDecoder().decode([Task].self, from: data)
                    completion(tasks, nil)
                } catch {
                    print("❌ JSON parsing error: \(error)")
                    completion(nil, error)
                }
            }
        }.resume()
    }
    
    func addTask(title: String, description: String?, completion: @escaping (Task?, Error?) -> Void) {
        guard let userId = SimpleAuthService.shared.currentUser?.id else {
            completion(nil, NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"]))
            return
        }
        
        let url = URL(string: "\(baseURL)/tasks")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Include userId in task data
        let taskData: [String: Any] = [
            "title": title,
            "description": description ?? "",
            "userId": userId
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: taskData)
        } catch {
            print("❌ JSON serialization error: \(error)")
            completion(nil, error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               (httpResponse.statusCode == 401 || httpResponse.statusCode == 403) {
                DispatchQueue.main.async {
                    SimpleAuthService.shared.logout()
                }
                completion(nil, NSError(domain: "AuthError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Authentication error"]))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("❌ Invalid response")
                completion(nil, NSError(domain: "APIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"]))
                return
            }
            
            if let data = data {
                do {
                    let task = try JSONDecoder().decode(Task.self, from: data)
                    completion(task, nil)
                } catch {
                    print("❌ JSON parsing error: \(error)")
                    completion(nil, error)
                }
            }
        }.resume()
    }
    
    func toggleTaskStatus(id: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = SimpleAuthService.shared.currentUser?.id else {
            completion(false, NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"]))
            return
        }
        
        let url = URL(string: "\(baseURL)/tasks/\(id)/toggle")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Include userId in request body
        let body: [String: Any] = ["userId": userId]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("❌ JSON serialization error: \(error)")
            completion(false, error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                completion(false, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               (httpResponse.statusCode == 401 || httpResponse.statusCode == 403) {
                DispatchQueue.main.async {
                    SimpleAuthService.shared.logout()
                }
                completion(false, NSError(domain: "AuthError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Authentication error"]))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("❌ Invalid response")
                completion(false, NSError(domain: "APIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"]))
                return
            }
            
            completion(true, nil)
        }.resume()
    }
    
    func deleteTask(id: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = SimpleAuthService.shared.currentUser?.id else {
            completion(false, NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"]))
            return
        }
        
        // Create URL with userId parameter
        guard var urlComponents = URLComponents(string: "\(baseURL)/tasks/\(id)") else {
            completion(false, NSError(domain: "InvalidURL", code: 0, userInfo: nil))
            return
        }
        
        // Add userId as query parameter
        urlComponents.queryItems = [URLQueryItem(name: "userId", value: userId)]
        
        guard let url = urlComponents.url else {
            completion(false, NSError(domain: "InvalidURL", code: 0, userInfo: nil))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                completion(false, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               (httpResponse.statusCode == 401 || httpResponse.statusCode == 403) {
                DispatchQueue.main.async {
                    SimpleAuthService.shared.logout()
                }
                completion(false, NSError(domain: "AuthError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Authentication error"]))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("❌ Invalid response")
                completion(false, NSError(domain: "APIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"]))
                return
            }
            
            completion(true, nil)
        }.resume()
    }
    
    // Add a new method for handling dueDate and priority
    func addTask(title: String, description: String, dueDate: String, priority: String, completion: @escaping (Task?, Error?) -> Void) {
        guard let userId = SimpleAuthService.shared.currentUser?.id else {
            completion(nil, NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"]))
            return
        }
        
        let url = URL(string: "\(baseURL)/tasks")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let taskData: [String: Any] = [
            "title": title,
            "description": description,
            "dueDate": dueDate,
            "priority": priority,
            "userId": userId
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: taskData)
        } catch {
            print("❌ JSON serialization error: \(error)")
            completion(nil, error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               (httpResponse.statusCode == 401 || httpResponse.statusCode == 403) {
                DispatchQueue.main.async {
                    SimpleAuthService.shared.logout()
                }
                completion(nil, NSError(domain: "AuthError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Authentication error"]))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("❌ Invalid response")
                completion(nil, NSError(domain: "APIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"]))
                return
            }
            
            if let data = data {
                do {
                    let task = try JSONDecoder().decode(Task.self, from: data)
                    completion(task, nil)
                } catch {
                    print("❌ JSON parsing error: \(error)")
                    completion(nil, error)
                }
            }
        }.resume()
    }
}
