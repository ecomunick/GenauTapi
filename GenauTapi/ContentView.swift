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
    @State private var streak: Int = 1 // Default streak
    @State private var showLeaderboard = false
    @State private var leaderboardData: [[String: Any]] = []
    
    // Audio player for natural TTS
    @State private var audioPlayer: AVPlayer?

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.1, blue: 0.2) // Dark background
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // HEADER: Logo + Streak
                HStack {
                    Image("tapi_1_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 60) // Smaller logo
                        .cornerRadius(10)
                    
                    VStack(alignment: .leading) {
                        Text("Genau Tapi!")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                        Text("AI German Coach")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // STREAK UI 🔥
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(streak)")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)
                        Text("Days")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(8)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.top, 40)
                .padding(.horizontal)

                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        // User Speech
                        if !speechRecognizer.transcript.isEmpty {
                            Text("YOU SAID:")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(speechRecognizer.transcript)
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                        } else {
                            Text("Say something in German...")
                                .font(.title3)
                                .italic()
                                .foregroundColor(.gray.opacity(0.5))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        }
                        
                        // AI Reply
                        if !replyText.isEmpty && replyText != "Tap mic to start..." {
                            Text("TAPI SAYS:")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.top)
                            Text(replyText)
                                .font(.title3)
                                .foregroundColor(.green)
                        }
                        
                        // Correction
                        if !correctionText.isEmpty {
                            Text("CORRECTION:")
                                .font(.caption)
                                .foregroundColor(.yellow)
                            Text(correctionText)
                                .font(.subheadline)
                                .foregroundColor(.yellow)
                                .padding(10)
                                .background(Color.yellow.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        // Pronunciation Tip
                        if !pronunciationTip.isEmpty {
                            Text("TIP: \(pronunciationTip)")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .padding(.top, 5)
                        }
                        
                        // Scores
                        if score > 0 {
                            HStack(spacing: 20) {
                                ScoreView(label: "Score", value: score, color: scoreColor(score))
                                ScoreView(label: "Grammar", value: grammarScore, color: .blue)
                                ScoreView(label: "Style", value: pronunciationScore, color: .purple)
                            }
                            .padding(.top, 10)
                        }
                    }
                    .padding()
                }

                Spacer()
                
                // STATUS & MIC
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                } else {
                    Button(action: {
                        if speechRecognizer.isRecording {
                            speechRecognizer.stopTranscribing()
                            performAnalysis()
                        } else {
                            resetState()
                            speechRecognizer.startTranscribing()
                        }
                    }) {
                        Image(systemName: speechRecognizer.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(speechRecognizer.isRecording ? .red : .blue)
                            .shadow(color: speechRecognizer.isRecording ? .red.opacity(0.5) : .blue.opacity(0.5), radius: 10)
                    }
                }

                Text(speechRecognizer.isRecording ? "Listening..." : "Tap to Speak")
                    .foregroundColor(.gray)
                
                // LEADERBOARD BTN
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
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            // Load streak from local storage
            streak = UserDefaults.standard.integer(forKey: "userStreak")
            if streak == 0 { streak = 1 }
        }
        .sheet(isPresented: $showLeaderboard) {
            LeaderboardView(leaderboardData: $leaderboardData)
        }
    }
    
    // View Helper
    func ScoreView(label: String, value: Int, color: Color) -> some View {
        VStack {
            Text("\(value)")
                .font(.title2)
                .bold()
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
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
    
    func speakWithIOSTTS(_ text: String) {
        // Fallback iOS TTS if audio not available
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "de-DE")
        utterance.rate = 0.4
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    @State private var memory: String = ""

    func performAnalysis() {
        guard !speechRecognizer.transcript.isEmpty else { return }
        isProcessing = true
        let lastTranscript = speechRecognizer.transcript
        speechRecognizer.stopTranscribing() // Stop transcribing after getting the transcript
        
        // Load memory if empty
        if memory.isEmpty {
            memory = UserDefaults.standard.string(forKey: "aiMemory") ?? ""
        }
        
        // Call Backend API
        // USING LAN IP for Device Support: 192.168.68.106
        guard let url = URL(string: "https://genautapi.onrender.com/chat") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Send memory context
        let body: [String: Any] = [
            "transcript": lastTranscript,
            "streak": streak,
            "memory": memory
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        print("Sending request to \(url.absoluteString) with body: \(body)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isProcessing = false
                
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
                        withAnimation {
                            self.replyText = (json["reply"] as? String) ?? "Error"
                            self.correctionText = (json["correction"] as? String) ?? ""
                            self.pronunciationTip = (json["pronunciation_tip"] as? String) ?? ""
                            
                            let gScore = (json["grammar_score"] as? Int) ?? 0
                            let pScore = (json["pronunciation_score"] as? Int) ?? 0
                            self.grammarScore = gScore
                            self.pronunciationScore = pScore
                            
                            // Calculate Total Score locally for consistency
                            self.score = (gScore + pScore) / 2
                            
                            // Update Memory & Persist
                            if let newMemory = json["memory"] as? String {
                                self.memory = newMemory
                                UserDefaults.standard.set(newMemory, forKey: "aiMemory")
                                print("🧠 Memory Updated: \(newMemory)")
                            }
                            
                            // Play OpenAI TTS audio if available
                            if let audioURL = json["audio_url"] as? String, !audioURL.isEmpty {
                                self.playAudioFromURL(audioURL)
                            } else {
                                // Fallback to iOS TTS if no audio
                                self.speakWithIOSTTS(self.replyText)
                            }
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
        let baseURL = "http://192.168.68.106:8000"
        guard let url = URL(string: baseURL + urlPath) else { return }
        
        print("▶️ Playing Audio: \(url.absoluteString)")
        
        // Ensure Audio Session is active for playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio Session Error: \(error)")
        }

        let playerItem = AVPlayerItem(url: url)
        audioPlayer = AVPlayer(playerItem: playerItem)
        audioPlayer?.volume = 1.0
        audioPlayer?.play()
    }
    
    // ... skipped speakWithIOSTTS ...
    
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
            // Setup Audio Session for BOTH Recording and Playback
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
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
            
            DispatchQueue.main.async {
                self.isRecording = true
            }
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
import SwiftUI

struct LeaderboardView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var leaderboardData: [[String: Any]]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.05, green: 0.1, blue: 0.2)
                    .ignoresSafeArea()
                
                VStack {
                    if leaderboardData.isEmpty {
                        Text("No data yet")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        List {
                            ForEach(Array(leaderboardData.enumerated()), id: \.offset) { index, entry in
                                HStack {
                                    Text("#\(index + 1)")
                                        .font(.title2)
                                        .foregroundColor(rankColor(index + 1))
                                        .frame(width: 50)
                                    
                                    VStack(alignment: .leading) {
                                        Text(entry["ip"] as? String ?? "Unknown")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Text("\(entry["location"] as? String ?? "Unknown Location")")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing) {
                                        Text("\(entry["top_score"] as? Int ?? 0)")
                                            .font(.title2)
                                            .bold()
                                            .foregroundColor(.green)
                                        Text("Best Score")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.vertical, 5)
                                .listRowBackground(Color.white.opacity(0.05))
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
                .navigationTitle("🏆 Leaderboard")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                        .foregroundColor(.purple)
                    }
                }
            }
        }
    }
    
    func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)
        default: return .white
        }
    }
}
