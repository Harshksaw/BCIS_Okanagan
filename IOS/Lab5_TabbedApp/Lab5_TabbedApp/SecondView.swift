import SwiftUI

struct SecondView: View {
    @State private var name: String = ""
    @AppStorage("sharedName") var sharedName: String = ""

    var body: some View {
        VStack {
            TextField("Enter your name", text: $name, onCommit: {
                hideKeyboard()
                sharedName = name
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            
            Text("Okay, \(sharedName)!")
                .font(.headline)
                .padding()
        }
        .padding()
        .onAppear {
            name = sharedName
        }
    }
    
    

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    SecondView()
}
