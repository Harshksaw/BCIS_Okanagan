import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var dueDate = Date().addingTimeInterval(24 * 60 * 60) // Default to tomorrow
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var showDueDatePicker = true
    @State private var taskPriority = "Medium"
    @State private var animateButton = false
    
    // Colors
    private let accentColor = Color(red: 0.0, green: 0.5, blue: 0.8) // Nice blue
    private let backgroundColor = Color(red: 0.85, green: 0.95, blue: 1.0) // Light yellow
    private let cardColor = Color.white
    private let borderColor = Color(red: 0.85, green: 0.85, blue: 0.85) // Light gray
    
    // Task priorities with associated colors
    private let priorities = ["Low", "Medium", "High"]
    private let priorityColors: [String: Color] = [
        "Low": Color(red: 0.4, green: 0.8, blue: 0.4),
        "Medium": Color(red: 0.0, green: 0.5, blue: 0.8),
        "High": Color(red: 0.9, green: 0.3, blue: 0.3)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color - light yellow
                backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Title card
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Task Title")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            TextField("Enter task title", text: $title)
                                .padding()
                                .background(cardColor)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(borderColor, lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
                        }
                        .padding(.horizontal)
                        
                        // Description card
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            ZStack(alignment: .topLeading) {
                                if description.isEmpty {
                                    Text("Enter task details (optional)")
                                        .foregroundColor(.gray.opacity(0.7))
                                        .padding(.horizontal, 10)
                                        .padding(.top, 10)
                                }
                                
                                TextEditor(text: $description)
                                    .frame(minHeight: 120)
                                    .padding(5)
                                    .background(Color.clear)
                            }
                            .background(cardColor)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(borderColor, lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
                        }
                        .padding(.horizontal)
                        
                        // Due Date card
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Due Date")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                Button(action: {
                                    withAnimation(.spring()) {
                                        showDueDatePicker.toggle()
                                    }
                                }) {
                                    HStack {
                                        Text(showDueDatePicker ? "Hide" : "Show")
                                        Image(systemName: showDueDatePicker ? "chevron.up" : "chevron.down")
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(accentColor)
                                }
                            }
                            
                            if showDueDatePicker {
                                DatePicker("", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(GraphicalDatePickerStyle())
                                    .frame(maxHeight: 400)
                                    .padding(.vertical, 10)
                                    .background(cardColor)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(borderColor, lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
                            } else {
                                HStack {
                                    Text(formattedDate)
                                        .foregroundColor(.black)
                                    Spacer()
                                    Image(systemName: "calendar")
                                        .foregroundColor(accentColor)
                                }
                                .padding()
                                .background(cardColor)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(borderColor, lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Priority picker
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Priority")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 8) {
                                ForEach(priorities, id: \.self) { priority in
                                    Button(action: {
                                        taskPriority = priority
                                    }) {
                                        Text(priority)
                                            .font(.subheadline)
                                            .padding(.vertical, 10)
                                            .frame(maxWidth: .infinity)
                                            .foregroundColor(taskPriority == priority ? .white : priorityColors[priority])
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(taskPriority == priority ?
                                                          priorityColors[priority] ?? accentColor :
                                                          Color.white)
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(priorityColors[priority] ?? accentColor, lineWidth: 1)
                                            )
                                            .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Submit button
                        Button(action: submitTask) {
                            HStack {
                                Spacer()
                                if isSubmitting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .padding(.horizontal, 5)
                                } else {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 18))
                                    Text("Add Task")
                                        .font(.headline)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(title.isEmpty ? Color.gray : accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                        }
                        .disabled(title.isEmpty || isSubmitting)
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.vertical)
                }
                
                // Success message overlay
                if showSuccess {
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18))
                            Text("Task Added Successfully!")
                                .font(.headline)
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                        .padding(.bottom, 20)
                    }
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut(duration: 0.3), value: showSuccess)
                    .zIndex(1)
                }
            }
            .navigationTitle("Create New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(accentColor)
                }
                
                ToolbarItem(placement: .principal) {
                    HStack {
                        Image(systemName: "checklist.checked")
                            .foregroundColor(accentColor)
                        Text("New Task")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
            }
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage ?? "An unknown error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: dueDate)
    }
    
    private func submitTask() {
        guard !title.isEmpty else { return }
        
        isSubmitting = true
        
        // Convert to ISO 8601 format for the API
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]
        let dueDateString = isoFormatter.string(from: dueDate)
        
        // Add task with the new fields including due date
        APIService.shared.addTask(
            title: title,
            description: description,
            dueDate: dueDateString,
            priority: taskPriority
        ) { task, error in
            DispatchQueue.main.async {
                isSubmitting = false
                
                if let error = error {
                    errorMessage = "Failed to add task: \(error.localizedDescription)"
                    showError = true
                } else if task != nil {
                    // Show success message
                    withAnimation {
                        showSuccess = true
                    }
                    
                    // Clear the form
                    title = ""
                    description = ""
                    dueDate = Date().addingTimeInterval(24 * 60 * 60)
                    
                    // Hide success message after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showSuccess = false
                        }
                        dismiss() // Return to task list
                    }
                }
            }
        }
    }
}

// Extension to the API service to support the new fields
extension APIService {
    func addTask(
        title: String,
        description: String,
        dueDate: String,
        priority: String,
        completion: @escaping (Task?, Error?) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/tasks") else {
            completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let params: [String: Any] = [
            "title": title,
            "description": description,
            "dueDate": dueDate,
            "priority": priority
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params)
        } catch {
            completion(nil, error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "No data", code: 0, userInfo: nil))
                return
            }
            
            do {
                let task = try JSONDecoder().decode(Task.self, from: data)
                completion(task, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
}

// Preview for SwiftUI Canvas
struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView()
    }
}
