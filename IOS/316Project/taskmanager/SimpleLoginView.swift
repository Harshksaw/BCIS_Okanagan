import SwiftUI

struct SimpleLoginView: View {
    @StateObject private var authService = SimpleAuthService.shared
    @State private var email = ""
    @State private var password = ""
    @State private var isLoginMode = true
    @State private var name = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // Colors
    private let gradientColors = [Color.blue.opacity(0.7), Color.purple.opacity(0.7)]
    private let accentColor = Color.blue
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: gradientColors),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            // Content
            VStack(spacing: 20) {
                // App logo and name
                VStack(spacing: 15) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                    
                    Text("Task Manager")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(isLoginMode ? "Sign in to your account" : "Create a new account")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 50)
                .padding(.bottom, 40)
                
                // Form fields in a card
                VStack(spacing: 20) {
                    if !isLoginMode {
                        // Name field (only for register)
                        TextField("Full Name", text: $name)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                    }
                    
                    // Email field
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                    
                    // Password field
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                    
                    // Error message
                    if let error = authService.error {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    
                    // Submit button
                    Button(action: handleSubmit) {
                        if authService.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(accentColor)
                                .cornerRadius(10)
                        } else {
                            Text(isLoginMode ? "Sign In" : "Create Account")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isFormValid ? accentColor : Color.gray)
                                .cornerRadius(10)
                        }
                    }
                    .disabled(authService.isLoading || !isFormValid)
                    .padding(.top, 10)
                    
                    // Toggle between login and register
                    Button(action: {
                        withAnimation {
                            isLoginMode.toggle()
                            resetForm()
                        }
                    }) {
                        Text(isLoginMode ? "Need an account? Sign Up" : "Already have an account? Sign In")
                            .foregroundColor(.white)
                    }
                    .padding(.vertical)
                }
                .padding(30)
                .background(Color.black.opacity(0.2))
                .cornerRadius(20)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        if isLoginMode {
            return !email.isEmpty && !password.isEmpty
        } else {
            return !name.isEmpty && !email.isEmpty && !password.isEmpty
        }
    }
    
    // MARK: - Methods
    
    private func handleSubmit() {
        if isLoginMode {
            // Login
            authService.login(email: email, password: password) { success in
                if !success {
                    showError(message: authService.error ?? "Login failed")
                }
            }
        } else {
            // Register
            authService.register(name: name, email: email, password: password) { success in
                if !success {
                    showError(message: authService.error ?? "Registration failed")
                }
            }
        }
    }
    
    private func resetForm() {
        authService.error = nil
        if isLoginMode {
            name = ""
        } else {
            // No need to reset when switching to register
        }
    }
    
    private func showError(message: String) {
        alertMessage = message
        showingAlert = true
    }
}

struct SimpleLoginView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleLoginView()
    }
}
