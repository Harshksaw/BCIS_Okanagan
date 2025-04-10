import SwiftUI

struct VoiceInputView: View {
    @StateObject private var voiceManager = VoiceToTextManager()
    @Binding var text: String
    @Binding var isPresented: Bool
    @State private var animateButton = false
    @State private var pulsate = false
    
    // Colors
    private let backgroundColor = Color(red: 0.95, green: 0.95, blue: 0.98)
    private let accentColor = Color.blue
    
    var body: some View {
        VStack(spacing: 25) {
            // Header
            HStack {
                Spacer()
                
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color.gray.opacity(0.7))
                }
            }
            .padding(.top)
            
            Spacer()
            
            // Recording indicator
            if voiceManager.isRecording {
                Text("Listening...")
                    .font(.title)
                    .foregroundColor(accentColor)
                    .padding(.bottom, 10)
                
                // Animated circles
                ZStack {
                    ForEach(0..<3) { i in
                        Circle()
                            .stroke(accentColor.opacity(0.8), lineWidth: 2)
                            .frame(width: 120 + CGFloat(i * 40), height: 120 + CGFloat(i * 40))
                            .scaleEffect(pulsate ? 1.2 : 0.8)
                            .opacity(pulsate ? 0.4 : 0.8)
                            .animation(
                                Animation.easeInOut(duration: 1.5)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(i) * 0.2),
                                value: pulsate
                            )
                    }
                    
                    Image(systemName: "mic.fill")
                        .font(.system(size: 50))
                        .foregroundColor(accentColor)
                        .frame(width: 100, height: 100)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
                .onAppear {
                    pulsate = true
                }
            } else {
                Text("Tap the microphone to start")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 10)
                
                Image(systemName: "mic.fill")
                    .font(.system(size: 50))
                    .foregroundColor(accentColor)
                    .frame(width: 100, height: 100)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
            
            // Recognized text
            Text(voiceManager.recognizedText)
                .font(.headline)
                .padding()
                .frame(minHeight: 100)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                )
                .padding(.horizontal)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 30) {
                // Record button
                Button(action: {
                    withAnimation(.spring()) {
                        if voiceManager.isRecording {
                            voiceManager.stopRecording()
                        } else {
                            voiceManager.startRecording()
                        }
                        
                        animateButton = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            animateButton = false
                        }
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(accentColor)
                            .frame(width: 70, height: 70)
                            .shadow(color: accentColor.opacity(0.5), radius: 8, x: 0, y: 4)
                        
                        if voiceManager.isRecording {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white)
                                .frame(width: 20, height: 20)
                        } else {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                        }
                    }
                    .scaleEffect(animateButton ? 1.1 : 1.0)
                }
                
                // Use text button
                Button(action: {
                    text = voiceManager.recognizedText
                    isPresented = false
                }) {
                    Text("Use Text")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 120)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(voiceManager.recognizedText.isEmpty ? Color.gray : Color.green)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                }
                .disabled(voiceManager.recognizedText.isEmpty)
            }
            .padding(.bottom, 40)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
        .edgesIgnoringSafeArea(.all)
        .alert(isPresented: $voiceManager.showErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(voiceManager.errorMessage ?? "An unknown error occurred"),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            // Check permissions when view appears
            voiceManager.checkPermissions()
        }
        .onDisappear {
            // Clean up when view disappears
            if voiceManager.isRecording {
                voiceManager.stopRecording()
            }
        }
    }
}

struct VoiceInputView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceInputView(text: .constant(""), isPresented: .constant(true))
    }
}
