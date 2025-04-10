import SwiftUI

struct TaskListView: View {
    @State private var tasks: [Task] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var showAddTaskSheet = false
    @State private var selectedTaskColor = 0
    @State private var animateList = false
    @State private var showCalendar = false
    @State private var selectedDate = Date()
    
    // New state to control welcome banner visibility
    @State private var showBanner = true

    // Color themes for tasks
    let taskColorThemes: [[Color]] = [
        [.blue, .blue.opacity(0.15)],               // Blue theme
        [.purple, .purple.opacity(0.15)],             // Purple theme
        [.green, .green.opacity(0.15)],               // Green theme
        [.orange, .orange.opacity(0.15)],             // Orange theme
        [.pink, .pink.opacity(0.15)],                 // Pink theme
        [.teal, .teal.opacity(0.15)],                 // Teal theme
        [.indigo, .indigo.opacity(0.15)]              // Indigo theme
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background with light blue color
                Color(red: 0.85, green: 0.95, blue: 1.0)
                    .edgesIgnoringSafeArea(.all)
                
                // Main content
                VStack {
                    // Conditionally show the welcome banner
                    if showBanner {
                        welcomeBanner
                            
                    }
                    
                    if isLoading {
                        LoadingView()
                    } else if let errorMessage = errorMessage {
                        ErrorView(message: errorMessage, retryAction: fetchTasks)
                    } else if tasks.isEmpty {
                        EmptyStateView(showAddTaskSheet: $showAddTaskSheet)
                    } else {
                        taskListView
                    }
                }
                .navigationTitle("My Tasks")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        // App Logo on left side
                        Image(systemName: "checklist.checked")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.green)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showCalendar.toggle()
                        }) {
                            Image(systemName: "calendar")
                                .font(.system(size: 22))
                                .foregroundColor(.blue)
                        }
                        .popover(isPresented: $showCalendar) {
                            calendarView
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
                .sheet(isPresented: $showAddTaskSheet) {
                    AddTaskSheetView(colorThemes: taskColorThemes, selectedColor: $selectedTaskColor, onAdd: { title, description in
                        addNewTask(title: title, description: description)
                        showAddTaskSheet = false
                    })
                }
            }
        }
        .onAppear {
            fetchTasks()
            // Hide the welcome banner after 3 seconds
        
            
        }
    }
    
    // Welcome banner view
    private var welcomeBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Dynamic greeting based on time of day
            Text(dynamicGreeting())
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            HStack {
                Text("Ready to crush your tasks today?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
        .padding(.horizontal)
        .padding(.top, 8)
        // Entrance animation
        .transition(.asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        ))
    }
    private func dynamicGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return "Good Morning!"
        case 12..<17:
            return "Good Afternoon!"
        case 17..<22:
            return "Good Evening!"
        default:
            return "Hello!"
        }
    }

    // Calendar popover view
    private var calendarView: some View {
        VStack {
            DatePicker(
                "Select Date",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(GraphicalDatePickerStyle())
            .padding()
            
            Divider()
            
            Button(action: {
                // Filter tasks by selected date (placeholder functionality)
                showCalendar = false
                // In a real app, you would filter tasks based on the selected date
            }) {
                Text("View Tasks for Selected Date")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .padding(.bottom)
        }
        .frame(width: 350, height: 450)
    }
    
    // Task list with animations and colors
    private var taskListView: some View {
        List {
            ForEach(Array(zip(tasks.indices, tasks)), id: \.1.id) { index, task in
                let colorIndex = index % taskColorThemes.count
                
                TaskRowEnhanced(
                    task: task,
                    onToggle: { toggleTask(task) },
                    colorScheme: taskColorThemes[colorIndex]
                )
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .padding(.vertical, 4)
                .swipeActions {
                    Button(role: .destructive) {
                        withAnimation {
                            deleteTask(task)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .transition(.slide)
                
            }
        }
        .listStyle(PlainListStyle())
        .refreshable {
            fetchTasks()
        }
    }
    
    // MARK: - Network Functions
    
    private func fetchTasks() {
        isLoading = true
        errorMessage = nil
        
        APIService.shared.fetchTasks { tasks, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = "Failed to load tasks: \(error.localizedDescription)"
                } else if let tasks = tasks {
                    withAnimation {
                        self.tasks = tasks
                    }
                } else {
                    errorMessage = "No tasks data received"
                }
            }
        }
    }
    
    private func addNewTask(title: String, description: String) {
        APIService.shared.addTask(title: title, description: description) { task, error in
            DispatchQueue.main.async {
                if error != nil {
                    errorMessage = "Failed to add task"
                    showError = true
                } else {
                    fetchTasks()
                }
            }
        }
    }
    
    private func toggleTask(_ task: Task) {
        APIService.shared.toggleTaskStatus(id: task.id) { success, error in
            DispatchQueue.main.async {
                if success {
                    fetchTasks()
                } else if let error = error {
                    errorMessage = "Failed to update task: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
    
    private func deleteTask(_ task: Task) {
        APIService.shared.deleteTask(id: task.id) { success, error in
            DispatchQueue.main.async {
                if success {
                    withAnimation {
                        // Optimistically remove from UI first for better UX
                        if let index = self.tasks.firstIndex(where: { $0.id == task.id }) {
                            self.tasks.remove(at: index)
                        }
                    }
                    // Then refresh from API
                    fetchTasks()
                } else if let error = error {
                    errorMessage = "Failed to delete task: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}

// Rest of the supporting views remain unchanged
struct TaskRowEnhanced: View {
    let task: Task
    let onToggle: () -> Void
    let colorScheme: [Color]
    @State private var isHovered = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.headline)
                    .foregroundColor(task.isDone ? .secondary : .primary)
                    .strikethrough(task.isDone, color: .secondary)
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                if let createdAt = task.createdAt {
                    Text(dateFormatter.string(from: createdAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .fill(task.isDone ? colorScheme[0] : Color.clear)
                        .frame(width: 28, height: 28)
                    
                    Circle()
                        .stroke(task.isDone ? colorScheme[0] : Color.gray, lineWidth: 2)
                        .frame(width: 28, height: 28)
                    
                    if task.isDone {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .scaleEffect(isHovered ? 1.1 : 1.0)
                .animation(.spring(response: 0.2), value: isHovered)
            }
            .buttonStyle(BorderlessButtonStyle())
          
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(task.isDone ? colorScheme[1].opacity(0.5) : colorScheme[1])
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(colorScheme[0], lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}

// Loading animation view
struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(Color.blue, lineWidth: 5)
                .frame(width: 60, height: 60)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                .onAppear {
                    isAnimating = true
                }
            
            Text("Loading your tasks...")
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

// Empty state view with updated design
struct EmptyStateView: View {
    @Binding var showAddTaskSheet: Bool
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: "list.bullet.rectangle.portrait")
                .font(.system(size: 70))
                .foregroundColor(.blue)
                .opacity(isAnimating ? 1.0 : 0.5)
                .scaleEffect(isAnimating ? 1.1 : 0.9)
                .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                .onAppear {
                    isAnimating = true
                }
            
            Text("No Tasks Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Start by adding your first task")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                showAddTaskSheet = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add New Task")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(15)
                .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 3)
            }
            .padding(.top, 10)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

// Error view with refreshed design
struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Oops!")
                .font(.title)
                .fontWeight(.bold)
            
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button(action: retryAction) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(15)
                .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 3)
            }
            .padding(.top, 10)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

// Add task sheet view with improved design
struct AddTaskSheetView: View {
    let colorThemes: [[Color]]
    @Binding var selectedColor: Int
    let onAdd: (String, String) -> Void
    
    @State private var title = ""
    @State private var description = ""
    @State private var dueDate = Date()
    @State private var showDatePicker = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Task Title", text: $title)
                        .font(.headline)
                    
                    TextField("Description (Optional)", text: $description)
                        .font(.subheadline)
                    
                    Button(action: {
                        showDatePicker.toggle()
                    }) {
                        HStack {
                            Text("Due Date")
                            Spacer()
                            Text(dateFormatter.string(from: dueDate))
                                .foregroundColor(.secondary)
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    if showDatePicker {
                        DatePicker("", selection: $dueDate, displayedComponents: [.date])
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .frame(maxHeight: 300)
                    }
                }
                
                Section(header: Text("Choose Color Theme")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(0..<colorThemes.count, id: \.self) { index in
                                Circle()
                                    .fill(colorThemes[index][0])
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                            .opacity(selectedColor == index ? 1 : 0)
                                    )
                                    .shadow(color: colorThemes[index][0].opacity(0.5), radius: 3, x: 0, y: 2)
                                    .onTapGesture {
                                        selectedColor = index
                                    }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                
                Section {
                    Button(action: {
                        guard !title.isEmpty else { return }
                        onAdd(title, description)
                    }) {
                        HStack {
                            Spacer()
                            Text("Add Task")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding()
                        .background(title.isEmpty ? Color.gray : colorThemes[selectedColor][0])
                        .cornerRadius(10)
                    }
                    .disabled(title.isEmpty)
                    .listRowBackground(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}

// Extension to make hover state work on iOS
extension View {
    func onHover(perform action: @escaping (Bool) -> Void) -> some View {
        #if os(macOS)
        return self.onHover(perform: action)
        #else
        return self // No-op on iOS
        #endif
    }
}
