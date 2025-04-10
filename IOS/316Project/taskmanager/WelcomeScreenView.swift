import SwiftUI

struct WelcomeScreensView: View {
    @Binding var showIntroScreens: Bool
    @State private var currentPage = 0
    @State private var timer: Timer?
    @State private var progress: CGFloat = 0.0
    
    let welcomeScreens = [
        WelcomeScreen(
            title: "Welcome to TaskZen",
            description: "A modern task manager built just for you.",
            systemImage: "checkmark.circle",
            accentColor: .blue,
            details: [
                "Intuitive Interface",
                "Seamless Task Management",
                "Personalized Productivity"
            ]
        ),
        WelcomeScreen(
            title: "Stay Focused & Productive",
            description: "Organize your tasks and track your time with ease.",
            systemImage: "list.bullet.rectangle",
            accentColor: .green,
            details: [
                "Smart Task Categorization",
                "Priority Tracking",
                "Distraction-Free Workspace"
            ]
        ),
        WelcomeScreen(
            title: "Pomodoro, Calendar & More",
            description: "Use timers, manage your schedule, and never miss a task!",
            systemImage: "timer",
            accentColor: .purple,
            details: [
                "Customizable Pomodoro Timers",
                "Integrated Calendar",
                "Comprehensive Task Insights"
            ]
        )
    ]
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [
                    welcomeScreens[currentPage].accentColor.opacity(0.1),
                    welcomeScreens[currentPage].accentColor.opacity(0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Progress Indicator
                HStack {
                    ForEach(0..<3) { index in
                        Capsule()
                            .fill(index <= currentPage ? welcomeScreens[currentPage].accentColor : Color.gray.opacity(0.3))
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal)
                
                // Main Content
                TabView(selection: $currentPage) {
                    ForEach(0..<3, id: \.self) { index in
                        VStack(spacing: 20) {
                            // Animated System Image
                            Image(systemName: welcomeScreens[index].systemImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .foregroundColor(welcomeScreens[index].accentColor)
                                .shadow(color: welcomeScreens[index].accentColor.opacity(0.3), radius: 15)
                                .scaleEffect(currentPage == index ? 1.0 : 0.8)
                                .animation(.spring(), value: currentPage)
                            
                            // Title
                            Text(welcomeScreens[index].title)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            // Description
                            Text(welcomeScreens[index].description)
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            // Detailed Features
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(welcomeScreens[index].details, id: \.self) { detail in
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(welcomeScreens[index].accentColor)
                                        Text(detail)
                                            .font(.subheadline)
                                    }
                                }
                            }
                            .padding()
                        }
                        .tag(index)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 500)
                
                // Navigation Button
                Button(action: {
                    withAnimation {
                        if currentPage < 2 {
                            currentPage += 1
                        } else {
                            stopTimer()
                            showIntroScreens = false
                        }
                    }
                }) {
                    Text(currentPage < 2 ? "Next" : "Get Started")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(welcomeScreens[currentPage].accentColor)
                        .cornerRadius(15)
                        .shadow(color: welcomeScreens[currentPage].accentColor.opacity(0.3), radius: 10)
                }
                .padding()
                .transition(.slide)
            }
        }
        .onAppear {
            startAutoAdvance()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func startAutoAdvance() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation {
                if currentPage < 2 {
                    currentPage += 1
                } else {
                    stopTimer()
                    showIntroScreens = false
                }
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// Struct to define welcome screen details
struct WelcomeScreen {
    let title: String
    let description: String
    let systemImage: String
    let accentColor: Color
    let details: [String]
}

// Preview for development
struct WelcomeScreensView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeScreensView(showIntroScreens: .constant(true))
            .preferredColorScheme(.light)
        
        WelcomeScreensView(showIntroScreens: .constant(true))
            .preferredColorScheme(.dark)
    }
}
