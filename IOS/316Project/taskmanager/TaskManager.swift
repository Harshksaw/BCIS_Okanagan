import SwiftUI

@main
struct TaskManagerApp: App {
    init() {
        // Set a color scheme that ensures text visibility
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.label]
    }

    var body: some Scene {
        WindowGroup {
            AuthenticatedContentView()
                .preferredColorScheme(.light)
        }
    }
}
