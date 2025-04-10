import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            TaskListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Tasks")
                }

            AddTaskView()
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("Add Task")
                }

            PomodoroView()
                .tabItem {
                    Label("Pomodoro", systemImage: "timer")
                }

            AboutView()
                .tabItem {
                    Image(systemName: "info.circle")
                    Text("About")
                }
        }
        .accentColor(.blue)
    }
}
