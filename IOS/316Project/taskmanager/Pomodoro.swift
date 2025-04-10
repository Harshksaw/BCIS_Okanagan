import SwiftUI

enum PomodoroMode {
    case work
    case shortBreak
    case longBreak
}

struct PomodoroView: View {
    @State private var timeRemaining = 25 * 60
    @State private var timerRunning = false
    @State private var pomodoroCount = 0
    @State private var mode: PomodoroMode = .work
    @State private var timer: Timer?

    var totalTime: Int {
        defaultDuration(for: mode)
    }

    var progress: CGFloat {
        1 - CGFloat(timeRemaining) / CGFloat(totalTime)
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "EBF5FB"), Color(hex: "D6EAF8")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Text(modeText())
                    .font(.title)
                    .foregroundColor(textColor())
                    .bold()

                ZStack {
                    Circle()
                        .stroke(lineWidth: 20)
                        .opacity(0.3)
                        .foregroundColor(accentColor())

                    Circle()
                        .trim(from: 0.0, to: progress)
                        .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                        .foregroundColor(accentColor())
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut, value: progress)

                    Text(timeString())
                        .font(.system(size: 48, design: .monospaced))
                        .bold()
                        .foregroundColor(textColor())
                }
                .frame(width: 250, height: 250)

                HStack(spacing: 40) {
                    Button(action: toggleTimer) {
                        Text(timerRunning ? "Pause" : "Start")
                            .frame(width: 100, height: 44)
                            .background(accentColor())
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: resetTimer) {
                        Text("Reset")
                            .frame(width: 100, height: 44)
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(textColor())
                            .cornerRadius(10)
                    }
                }

                Text("Completed: \(pomodoroCount) 🍅")
                    .font(.headline)
                    .foregroundColor(textColor())
            }
            .padding()
        }
    }

    // MARK: - Utility Methods

    func modeText() -> String {
        switch mode {
        case .work: return "Focus Time"
        case .shortBreak: return "Short Break"
        case .longBreak: return "Long Break"
        }
    }

    func timeString() -> String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func toggleTimer() {
        if timerRunning {
            timer?.invalidate()
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    timer?.invalidate()
                    advanceCycle()
                }
            }
        }
        timerRunning.toggle()
    }

    func resetTimer() {
        timer?.invalidate()
        timerRunning = false
        timeRemaining = defaultDuration(for: mode)
    }

    func advanceCycle() {
        withAnimation {
            switch mode {
            case .work:
                pomodoroCount += 1
                mode = pomodoroCount % 4 == 0 ? .longBreak : .shortBreak
            default:
                mode = .work
            }
            timeRemaining = defaultDuration(for: mode)
        }
    }

    func defaultDuration(for mode: PomodoroMode) -> Int {
        switch mode {
        case .work: return 25 * 60
        case .shortBreak: return 5 * 60
        case .longBreak: return 15 * 60
        }
    }

    func accentColor() -> Color {
        switch mode {
        case .work: return Color(hex: "3498DB")
        case .shortBreak: return Color(hex: "58D68D")
        case .longBreak: return Color(hex: "F39C12")
        }
    }

    func textColor() -> Color {
        return Color(hex: "2C3E50")
    }
}
extension Color {
    init(hex hexString: String) {
        let hex = hexString.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xff, int & 0xff)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xff, int >> 8 & 0xff, int & 0xff)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
