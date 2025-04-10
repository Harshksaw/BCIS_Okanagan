import Foundation
import Speech
import AVFoundation
import SwiftUI

class VoiceToTextManager: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    @Published var isRecording = false
    @Published var recognizedText = ""
    @Published var errorMessage: String?
    @Published var showErrorAlert = false
    @Published var permissionGranted = false
    
    private let speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    override init() {
        // Initialize with the appropriate locale for the user
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        
        super.init()
        
        speechRecognizer?.delegate = self
        
        // Check initial permission status
        checkPermissions()
    }
    
    deinit {
        stopRecording()
    }
    
    func checkPermissions() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self?.permissionGranted = true
                case .denied, .restricted, .notDetermined:
                    self?.permissionGranted = false
                    self?.errorMessage = "Speech recognition permission not granted"
                    self?.showErrorAlert = true
                @unknown default:
                    self?.permissionGranted = false
                    self?.errorMessage = "Unknown authorization status"
                    self?.showErrorAlert = true
                }
            }
        }
        
        // Also check microphone permission
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                if !granted {
                    self?.permissionGranted = false
                    self?.errorMessage = "Microphone permission not granted"
                    self?.showErrorAlert = true
                }
            }
        }
    }
    
    func startRecording() {
        // Clear previous recording session
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        // Set up audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "Failed to set up audio session: \(error.localizedDescription)"
            showErrorAlert = true
            return
        }
        
        // Configure the recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        // Get the input node from audio engine - it's not optional in newer versions of Swift
        let inputNode = audioEngine.inputNode
        
        // Ensure request exists
        guard let recognitionRequest = recognitionRequest else {
            errorMessage = "Unable to create recognition request"
            showErrorAlert = true
            return
        }
        
        // Configure request for real-time recognition
        recognitionRequest.shouldReportPartialResults = true
        
        // Start recognition
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            var isFinal = false
            
            if let result = result {
                // Update the recognized text
                self.recognizedText = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            // Handle errors or completion
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.isRecording = false
            }
        }
        
        // Configure the audio input
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        // Start the audio engine
        do {
            audioEngine.prepare()
            try audioEngine.start()
            isRecording = true
        } catch {
            errorMessage = "Failed to start audio engine: \(error.localizedDescription)"
            showErrorAlert = true
            isRecording = false
        }
    }
    
    func stopRecording() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            isRecording = false
        }
    }
    
    func resetText() {
        recognizedText = ""
    }
}
