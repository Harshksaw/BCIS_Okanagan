import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            FirstView()
                .tabItem {
                    Image(systemName: "1.circle")
                    Text("First")
                }
            
            SecondView()
                .tabItem {
                    Image(systemName: "2.circle")
                    Text("Second")
                }
        }
    }
}

#Preview {
    ContentView()
}
