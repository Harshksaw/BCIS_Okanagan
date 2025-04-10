import SwiftUI

struct ProfileView: View {
    @StateObject private var authService = SimpleAuthService.shared
    @State private var showLogoutConfirmation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile header
                    HStack(spacing: 20) {
                        // User initial avatar
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 80, height: 80)
                            
                            Text(getInitials())
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(Color.blue)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(authService.currentUser?.name ?? "User")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(authService.currentUser?.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
                    
                    // Account Info
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Account Information")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Divider()
                        
                        InfoRow(title: "User ID", value: authService.currentUser?.id ?? "N/A")
                        
                        Divider()
                        
                        InfoRow(title: "Joined", value: formatDate())
                        
                        Divider()
                        
                        InfoRow(title: "Account Type", value: "Standard")
                    }
                    .padding(.vertical)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
                    
                    // App Info
                    VStack(alignment: .leading, spacing: 15) {
                        Text("App Information")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Divider()
                        
                        InfoRow(title: "Version", value: "1.0.0")
                        
                        Divider()
                        
                        InfoRow(title: "Build", value: "2025.04.1")
                    }
                    .padding(.vertical)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
                    
                    // Logout Button
                    Button(action: {
                        showLogoutConfirmation = true
                    }) {
                        HStack {
                            Spacer()
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Logout")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(15)
                    }
                    .padding(.vertical)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Profile")
            .alert(isPresented: $showLogoutConfirmation) {
                Alert(
                    title: Text("Logout"),
                    message: Text("Are you sure you want to logout?"),
                    primaryButton: .destructive(Text("Logout")) {
                        authService.logout()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    private func getInitials() -> String {
        guard let name = authService.currentUser?.name, !name.isEmpty else {
            return "U"
        }
        
        let components = name.components(separatedBy: " ")
        if components.count > 1, let first = components.first?.first, let last = components.last?.first {
            return String(first) + String(last)
        } else if let first = components.first?.first {
            return String(first)
        }
        
        return "U"
    }
    
    private func formatDate() -> String {
        guard let createdAtString = authService.currentUser?.createdAt,
              let date = ISO8601DateFormatter().date(from: createdAtString) else {
            return "Unknown"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .padding(.horizontal)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
