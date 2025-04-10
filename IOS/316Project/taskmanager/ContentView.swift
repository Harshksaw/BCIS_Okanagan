import SwiftUI

struct ContentView: View {
    @State private var showIntroScreens = true

    var body: some View {
        NavigationStack {
            if showIntroScreens {
                WelcomeScreensView(showIntroScreens: $showIntroScreens)
            } else {
                MainTabView()
            }
        }
    }
}
