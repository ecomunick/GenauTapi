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
            
            VStack {
                Text("Select Translation Mode:")
                Picker("Language", selection: $model.sourceLang) {
                    Text("🇩🇪 Deutsch → 🇺🇸 English").tag("de-DE")
                    Text("🇺🇸 English → 🇩🇪 Deutsch").tag("en-US")
                }
                .pickerStyle(.segmented)
                .onChange(of: model.sourceLang) { _ in
                    model.toggleLanguage()
                }
            }
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
                // Spacer to balance
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
                        
                        if model.showCorrection {
                             Text(model.correction)
                                .font(.footnote)
                                .foregroundColor(.red)
                                .padding(.top, 5)
                            
                             Text("Woof! 🐕 Score: 85/100 🎉") // Mock score as per instructions
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
