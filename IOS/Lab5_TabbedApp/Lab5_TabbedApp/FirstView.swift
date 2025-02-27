import SwiftUI

struct FirstView: View {
    @State private var name: String = ""
    @State private var appointmentDate: Date = Date()
    @AppStorage("sharedName") var sharedName: String = ""

    var body: some View {
        VStack {
            DatePicker("", selection: $appointmentDate, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(WheelDatePickerStyle())
                .padding()

            TextField("Enter your name", text: $name, onCommit: {
                hideKeyboard()
                sharedName = name
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .submitLabel(.done)  // Improves keyboard return behavior
            .padding()

            Text("Selected Date: \(formattedDate)")
                .padding(.top)

            Text("Okay, \(sharedName)!")  // Display name from SecondView
                .font(.headline)
                .padding(.top)
        }
        .padding()
        .onAppear {
            name = sharedName  // Load name from storage
        }
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: appointmentDate)
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    FirstView()
}
