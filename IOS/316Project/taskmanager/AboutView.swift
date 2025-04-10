import SwiftUI

struct AboutView: View {
    // Gradient colors for background
    let gradientColors = [Color.blue.opacity(0.8), Color.purple.opacity(0.7)]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(gradient: Gradient(colors: gradientColors),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        // App header with logo
                        HStack(spacing: 15) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                            
                            VStack(alignment: .leading) {
                                Text("Task Manager")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Todo App")
                                    .font(.title2)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        .padding(.top, 20)
                        
                        // Developer info card
                        InfoCard(
                            title: "Developer",
                            content: "Parag Jindal",
                            icon: "person.fill",
                            iconColor: .blue
                        )
                        
                        // Project info card
                        InfoCard(
                            title: "Project",
                            content: "CS316 iOS Project",
                            icon: "doc.fill",
                            iconColor: .orange
                        )
                        
                        // Tech stack card
                        InfoCard(
                            title: "Technology Stack",
                            content: "SwiftUI 5\nNode.js Backend\nRunning on Ubuntu Server",
                            icon: "server.rack",
                            iconColor: .green
                        )
                        
                        // Date card
                        InfoCard(
                            title: "Released",
                            content: "April 2025",
                            icon: "calendar",
                            iconColor: .pink
                        )
                        
                        // Features card
                        InfoCard(
                            title: "Features",
                            content: "• Create and manage tasks\n• Mark tasks as complete\n• Delete completed tasks\n• Cloud synchronization",
                            icon: "list.bullet.rectangle",
                            iconColor: .purple
                        )
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.black.opacity(0.8), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

// Card view for information display
struct InfoCard: View {
    let title: String
    let content: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Card header with icon
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(iconColor)
                    .frame(width: 30)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            // Card content
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.leading, 36)
                .lineSpacing(4)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
