import SwiftUI
import Speech
import AVFoundation

struct ContentView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var replyText: String = "Tap mic to start..."
    @State private var correctionText: String = ""
    @State private var pronunciationTip: String = ""
    @State private var score: Int = 0
    @State private var grammarScore: Int = 0
    @State private var pronunciationScore: Int = 0
    @State private var isProcessing = false
    @State private var lastTranscript: String = ""
    @State private var showLeaderboard = false
    @State private var leaderboardData: [[String: Any]] = []
    
    // Audio player for natural TTS
    @State private var audioPlayer: AVPlayer?

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.1, blue: 0.2) // Dark background
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                VStack {
                    Image("tapi_1_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        
                    Text("Genau Tapi!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))
                    Text("Speak & Learn")
                        .foregroundColor(.gray)
                }

                Spacer()

                // Result Area
                VStack(alignment: .leading, spacing: 10) {
                    Text("YOU SAID:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(speechRecognizer.transcript.isEmpty ? "..." : speechRecognizer.transcript)
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                    
                    if !replyText.isEmpty {
                        Text("TAPI SAYS:")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top)
                        Text(replyText)
                            .font(.title3)
                            .foregroundColor(.green)
                    }
                    
                    if !correctionText.isEmpty {
                        Text("CORRECTION: \(correctionText)")
                            .font(.subheadline)
                            .foregroundColor(.yellow)
                            .padding(.top, 5)
                            .transition(.opacity)
                    }
                    
                    if !pronunciationTip.isEmpty {
                        Text("TIP: \(pronunciationTip)")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(.top, 5)
                            .transition(.opacity)
                    }
                    
                    // Score Display
                    if score > 0 {
                        HStack(spacing: 15) {
                            VStack {
                                Text("\(score)")
                                    .font(.title)
                                    .foregroundColor(scoreColor(score))
                                Text("Total")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            VStack {
                                Text("\(grammarScore)")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                                Text("Grammar")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            VStack {
                                Text("\(pronunciationScore)")
                                    .font(.title3)
                                    .foregroundColor(.purple)
                                Text("Accent")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.top, 10)
                    }
                }
                .padding()

                Spacer()
                
                // Mic Button
                Button(action: {
                    if speechRecognizer.isRecording {
                        speechRecognizer.stopTranscribing()
                        performAnalysis()
                    } else {
                        resetState()
                        speechRecognizer.startTranscribing()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(speechRecognizer.isRecording ? Color.red : Color.purple)
                            .frame(width: 80, height: 80)
                            .shadow(color: speechRecognizer.isRecording ? .red : .purple, radius: 10)
                        
                        Image(systemName: speechRecognizer.isRecording ? "stop.fill" : "mic.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                .overlay(
                    Group {
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .offset(y: 60)
                        }
                    }
                )

                Text(speechRecognizer.isRecording ? "Listening..." : "Tap to Speak")
                    .foregroundColor(.gray)
                
                // Leaderboard Button
                Button(action: {
                    fetchLeaderboard()
                    showLeaderboard = true
                }) {
                    HStack {
                        Image(systemName: "list.number")
                        Text("Leaderboard")
                    }
                    .font(.callout)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.purple.opacity(0.3))
                    .cornerRadius(20)
                }
                .padding(.top, 10)
            }
            .padding()
        }
        .sheet(isPresented: $showLeaderboard) {
            LeaderboardView(leaderboardData: $leaderboardData)
        }
    }
    
    func scoreColor(_ score: Int) -> Color {
        if score >= 80 { return .green }
        if score >= 60 { return .orange }
        return .red
    }
    
    func resetState() {
        replyText = ""
        correctionText = ""
        pronunciationTip = ""
        isProcessing = false
    }
    
    func performAnalysis() {
        guard !speechRecognizer.transcript.isEmpty else { return }
        isProcessing = true
        lastTranscript = speechRecognizer.transcript
        
        // Call Backend API
        // USING LAN IP for Device Support: 192.168.68.106
        guard let url = URL(string: "http://192.168.68.106:8000/chat") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["transcript": lastTranscript]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        print("Sending request to \(url.absoluteString) with body: \(body)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isProcessing = false
                
                if let error = error {
                    print("Network Error: \(error.localizedDescription)")
                    self.replyText = "Net Error: \(error.localizedDescription)"
                    return
                }
                
                if let data = data {
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Raw Response: \(responseString)")
                    }
                    
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        self.replyText = (json["reply"] as? String) ?? "Error"
                        self.correctionText = (json["correction"] as? String) ?? ""
                        self.pronunciationTip = (json["pronunciation_tip"] as? String) ?? ""
                        self.score = (json["score"] as? Int) ?? 0
                        self.grammarScore = (json["grammar_score"] as? Int) ?? 0
                        self.pronunciationScore = (json["pronunciation_score"] as? Int) ?? 0
                        
                        // Play OpenAI TTS audio if available
                        if let audioURL = json["audio_url"] as? String, !audioURL.isEmpty {
                            playAudioFromURL(audioURL)
                        } else {
                            // Fallback to iOS TTS if no audio
                            speakWithIOSTTS(self.replyText)
                        }
                    } else {
                        print("JSON Parsing Failed")
                        self.replyText = "Error: Invalid JSON from Server"
                    }
                } else {
                     print("No Data Received")
                     self.replyText = "Error: No Data"
                }
            }
        }.resume()
    }
    
    func playAudioFromURL(_ urlPath: String) {
        // Construct full URL
        let baseURL = "http://192.168.68.106:8000"
        guard let url = URL(string: baseURL + urlPath) else {
            print("Invalid audio URL")
            return
        }
        
        // Create and play audio
        let playerItem = AVPlayerItem(url: url)
        audioPlayer = AVPlayer(playerItem: playerItem)
        audioPlayer?.play()
    }
    
    func speakWithIOSTTS(_ text: String) {
        // Fallback iOS TTS if audio not available
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "de-DE")
        utterance.rate = 0.4
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    func fetchLeaderboard() {
        guard let url = URL(string: "http://192.168.68.106:8000/leaderboard") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    self.leaderboardData = json
                }
            }
        }.resume()
    }
}

// --- Simple Speech Recognizer Helper ---
class SpeechRecognizer: ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "de-DE"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    @Published var transcript = ""
    @Published var isRecording = false
    
    func startTranscribing() {
        guard !isRecording else { return }
        transcript = ""
        
        do {
            // Setup Audio Session
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else { return }
            recognitionRequest.shouldReportPartialResults = true
            
            let inputNode = audioEngine.inputNode
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
                if let result = result {
                    DispatchQueue.main.async {
                        self.transcript = result.bestTranscription.formattedString
                    }
                }
                if error != nil || (result?.isFinal ?? false) {
                    self.stopTranscribing()
                }
            }
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                recognitionRequest.append(buffer)
            }
            
            try audioEngine.start()
            isRecording = true
        } catch {
            print("Speech Rec Error: \(error)")
            stopTranscribing()
        }
    }
    
    func stopTranscribing() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel() 
        // Note: .finish() is better but for simple toggle stop/cancel is ok
        
        isRecording = false
    }
}
