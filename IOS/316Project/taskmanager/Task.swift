import Foundation

struct Task: Identifiable, Codable {
    // MongoDB ID is a string
    var id: String
    var title: String
    var description: String
    var isDone: Bool
    var createdAt: Date?
    
    // Optional properties with default values
    var dueDate: Date?
    var priority: TaskPriority?
    var userId: String?

    // Enum for standardized priority levels
    enum TaskPriority: String, Codable {
        case Low
        case Medium
        case High
        case urgent
    }

    // Customized CodingKeys to handle potential JSON variations
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case description
        case isDone
        case createdAt
        case dueDate
        case priority
        case userId
    }

    // Enhanced initializer with more comprehensive default handling
    init(
        id: String = UUID().uuidString,
        title: String,
        description: String = "",
        isDone: Bool = false,
        createdAt: Date? = Date(),
        dueDate: Date? = nil,
        priority: TaskPriority? = .Low,
        userId: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.isDone = isDone
        self.createdAt = createdAt ?? Date()
        self.dueDate = dueDate
        self.priority = priority
        self.userId = userId
    }

    // Custom decoder to handle potential data inconsistencies
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode basic required fields
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        isDone = try container.decodeIfPresent(Bool.self, forKey: .isDone) ?? false
        
        // Handle createdAt with flexible parsing
        if let createdAtString = try? container.decodeIfPresent(String.self, forKey: .createdAt) {
            let formatter = ISO8601DateFormatter()
            createdAt = formatter.date(from: createdAtString)
        } else {
            createdAt = Date()
        }
        
        // Flexible decoding for optional fields
        dueDate = try? container.decodeIfPresent(Date.self, forKey: .dueDate)
        priority = try? container.decodeIfPresent(TaskPriority.self, forKey: .priority)
        userId = try? container.decodeIfPresent(String.self, forKey: .userId)
    }
}

// Extended sample data with more comprehensive examples

// Optional: Add some utility methods
extension Task {
    // Method to update task status
    mutating func toggleDone() {
        isDone.toggle()
    }
    
    // Method to update priority
    mutating func updatePriority(to newPriority: TaskPriority) {
        priority = newPriority
    }
}
