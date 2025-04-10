import SwiftUI

struct AuthenticatedContentView: View {
    @StateObject private var authService = SimpleAuthService.shared
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                // User is logged in, show main content
                MainTabView()
            } else {
                // User is not logged in, show login view
                SimpleLoginView()
            }
        }
    }
}

struct AuthenticatedContentView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticatedContentView()
    }
}
