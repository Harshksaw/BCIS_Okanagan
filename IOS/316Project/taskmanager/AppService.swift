import Foundation

class APIService {
    static let shared = APIService()
    
    // Base URL of your Node.js API - update this when deploying
     let baseURL = "http://localhost:3000/api"
    
    private init() {}
    
    // MARK: - API Calls
    
    func fetchTasks(completion: @escaping ([Task]?, Error?) -> Void) {
        let url = URL(string: "\(baseURL)/tasks")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Status Code: \(httpResponse)")
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
        let url = URL(string: "\(baseURL)/tasks")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let taskData: [String: Any] = [
            "title": title,
            "description": description ?? ""
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
        let url = URL(string: "\(baseURL)/tasks/\(id)/toggle")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                completion(false, error)
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
        let url = URL(string: "\(baseURL)/tasks/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                completion(false, error)
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
}
