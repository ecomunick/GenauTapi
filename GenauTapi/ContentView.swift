import SwiftUI

struct ContentView: View {
    @StateObject private var model = GenauTapiModel()
    @State private var currentScreen: String = "welcome" // welcome, topics, chat, profile
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()
            
            switch currentScreen {
            case "welcome":
                WelcomeView(model: model, currentScreen: $currentScreen)
            case "chat":
                ChatView(model: model, currentScreen: $currentScreen)
            case "profile":
                ProfileView(model: model, currentScreen: $currentScreen)
            default:
                WelcomeView(model: model, currentScreen: $currentScreen)
            }
        }
    }
}

// MARK: - Welcome View
struct WelcomeView: View {
    @ObservedObject var model: GenauTapiModel
    @Binding var currentScreen: String
    
    var body: some View {
        VStack(spacing: 30) {
            Text("GenauTapi 🐶")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Practice speaking like a local!")
                .font(.title3)
                .foregroundColor(.gray)
            
            Spacer()
            
            
            Text("🇩🇪 Speak German, Learn German!")
                .font(.title2)
                .foregroundColor(.blue)
                .padding()
            
            
            Button(action: { currentScreen = "chat" }) {
                Text("Start Practice")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}

// TopicView Removed for Immersion Mode

// MARK: - Chat View
struct ChatView: View {
    @ObservedObject var model: GenauTapiModel
    @Binding var currentScreen: String
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Button(action: { currentScreen = "welcome" }) {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                }
                Spacer()
                Text("GenauTapi Chat 🇩🇪")
                    .font(.headline)
                Spacer()
                Button(action: { currentScreen = "profile" }) {
                    Text("🐶")
                        .font(.largeTitle)
                }
            }
            .padding()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if !model.transcript.isEmpty {
                        Text("You said:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(model.transcript)
                            .font(.body)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                    }
                    
                    if model.isProcessing {
                        HStack {
                            Text("Tapi is thinking...")
                            ProgressView()
                        }
                    }
                    
                    if !model.reply.isEmpty {
                        HStack {
                            Text("🐶 Tapi:")
                                .font(.headline)
                            Spacer()
                        }
                        Text(model.reply)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(10)
                        
                        if model.showCorrection && model.score > 0 {
                             Text("Score: \(model.score)/100 🎉")
                                .font(.caption)
                                .bold()
                                .padding(.top, 5)
                        }
                    }
                }
                .padding()
            }
            
            Spacer()
            
            // Speak Button
            Button(action: {
                if model.isRecording {
                    model.stopRecording()
                } else {
                    model.startRecording()
                }
            }) {
                VStack {
                    Image(systemName: model.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .foregroundColor(model.isRecording ? .red : .blue)
                    
                    Text(model.isRecording ? "Stop" : "🎤 Sprechen!")
                        .font(.headline)
                }
            }
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @ObservedObject var model: GenauTapiModel
    @Binding var currentScreen: String
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Button(action: { currentScreen = "chat" }) {
                    Text("Close")
                }
                Spacer()
                Text("Profile")
                    .bold()
                Spacer()
            }
            .padding()
            
            Image(systemName: "pawprint.circle.fill") // Placeholder for dog mascot
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.brown)
            
            Text("GenauTapi Leaderboard")
                .font(.title2)
            
            HStack(spacing: 40) {
                VStack {
                    Text("XP Points")
                        .foregroundColor(.gray)
                    Text("\(model.xp)")
                        .font(.largeTitle)
                        .bold()
                }
                VStack {
                    Text("Day Streak")
                        .foregroundColor(.gray)
                    Text("\(model.streak) 🔥")
                        .font(.largeTitle)
                        .bold()
                }
            }
            
            if model.xp >= 100 {
                Text("Level: Good Boy 🐶")
                    .font(.headline)
                    .foregroundColor(.green)
            }
            
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
