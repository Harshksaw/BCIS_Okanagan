import Foundation

struct Task: Identifiable, Codable {
    // MongoDB ID is a string
    var id: String
    var title: String
    var description: String
    var isDone: Bool
    var createdAt: Date?
    
    // Custom CodingKeys to map between Swift and MongoDB naming
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case description
        case isDone
        case createdAt
    }
    init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: CodingKeys.self)
           id = try container.decode(String.self, forKey: .id)
           title = try container.decode(String.self, forKey: .title)
           description = try container.decode(String.self, forKey: .description)
           isDone = try container.decode(Bool.self, forKey: .isDone)
           
           // Parse `createdAt` as ISO 8601 string
           if let createdAtString = try? container.decode(String.self, forKey: .createdAt) {
               let formatter = ISO8601DateFormatter()
               createdAt = formatter.date(from: createdAtString)
           } else {
               createdAt = nil
           }
       }
    
    init(id: String, title: String, description: String = "", isDone: Bool = false, createdAt: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.isDone = isDone
        self.createdAt = createdAt
    }
}

// Extension to create a sample task for previews
extension Task {
    static var sampleTask: Task {
        Task(id: "sample123", title: "Sample Task", description: "This is a sample task", isDone: false)
    }
    
    static var sampleTasks: [Task] {
        [
            Task(id: "1", title: "Complete project", description: "Finish the iOS project", isDone: false),
            Task(id: "2", title: "Buy groceries", description: "Milk, eggs, bread", isDone: true),
            Task(id: "3", title: "Call mom", description: "", isDone: false)
        ]
    }
}
