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
            
            WeatherView()
                .tabItem {
                    Image(systemName: "cloud.sun.fill")
                    Text("Weather")
                }

            PomodoroView()
                .tabItem {
                    Label("Pomodoro", systemImage: "timer")
                }

            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
        }
        .accentColor(.blue)
    }
}
