import Foundation
import SwiftUI
import Speech
import AVFoundation

class GenauTapiModel: NSObject, ObservableObject, SFSpeechRecognizerDelegate, AVSpeechSynthesizerDelegate {
    
    // MARK: - Published State
    @Published var transcript: String = ""
    @Published var reply: String = ""
    @Published var correction: String = ""
    @Published var isRecording: Bool = false
    @Published var isProcessing: Bool = false
    @Published var showCorrection: Bool = false
    
    // User Settings
    @Published var selectedTopic: String = "Daily Life"
    @Published var sourceLang: String = "de-DE" // defaulting to German -> English
    @Published var targetLang: String = "en-US"
    
    // Gamification
    @Published var xp: Int = UserDefaults.standard.integer(forKey: "xp_total")
    @Published var streak: Int = UserDefaults.standard.integer(forKey: "streak_days")
    @Published var lastStreakDate: Date? = UserDefaults.standard.object(forKey: "last_streak_date") as? Date

    // MARK: - Internal Properties
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var speechRecognizer: SFSpeechRecognizer?
    
    // Backend URL - Replace with actual Render URL after deployment
    private let backendURL = "https://genautapi.onrender.com/chat" 

    override init() {
        super.init()
        speechSynthesizer.delegate = self
        setupSpeech()
        checkStreak()
    }
    
    // MARK: - Speech Recognition
    private func setupSpeech() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: sourceLang))
        speechRecognizer?.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            // Handle auth status
        }
    }
    
    func toggleLanguage() {
        if sourceLang == "de-DE" {
            sourceLang = "en-US"
            targetLang = "de-DE"
        } else {
            sourceLang = "de-DE"
            targetLang = "en-US"
        }
        setupSpeech() // Re-init recognizer with new locale
    }
    
    func startRecording() {
        if isRecording { return }
        
        // Cancel previous task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio setup failed")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.transcript = result.bestTranscription.formattedString
                }
            }
            if error != nil || (result?.isFinal ?? false) {
                self.stopRecording()
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
            isRecording = true
            transcript = ""
            reply = ""
            showCorrection = false
        } catch {
            print("Engine start failed")
        }
    }
    
    func stopRecording() {
        if !isRecording { return }
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        isRecording = false
        
        // Send to API
        if !transcript.isEmpty {
            sendToBackend()
        }
    }
    
    // MARK: - Backend Interaction
    func sendToBackend() {
        guard let url = URL(string: backendURL) else { return }
        isProcessing = true
        
        let body: [String: Any] = [
            "transcript": transcript,
            "source_lang": sourceLang,
            "target_lang": targetLang,
            "topic": selectedTopic
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isProcessing = false
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    self.reply = json["reply"] as? String ?? "Error"
                    self.correction = json["correction"] as? String ?? ""
                    let newXp = json["xp"] as? Int ?? 0
                    self.updateXP(amount: newXp)
                    self.speak(text: self.reply)
                    self.showCorrection = true
                }
            }
        }.resume()
    }
    
    // MARK: - TTS
    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: targetLang)
        speechSynthesizer.speak(utterance)
    }
    
    // MARK: - Gamification
    func updateXP(amount: Int) {
        xp += amount
        UserDefaults.standard.set(xp, forKey: "xp_total")
        updateStreak()
    }
    
    func checkStreak() {
        // Simple streak logic
        // If last streak date was yesterday, ok. If older, reset.
        if let lastDate = lastStreakDate {
            if !Calendar.current.isDateInYesterday(lastDate) && !Calendar.current.isDateInToday(lastDate) {
                 streak = 0
            }
        }
    }
    
    func updateStreak() {
        if lastStreakDate == nil || !Calendar.current.isDateInToday(lastStreakDate!) {
            streak += 1
            lastStreakDate = Date()
            UserDefaults.standard.set(streak, forKey: "streak_days")
            UserDefaults.standard.set(lastStreakDate, forKey: "last_streak_date")
        }
    }
}
