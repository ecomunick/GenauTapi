import SwiftUI

struct ContentView: View {
    @ObservedObject private var recorder = Recorder()
    @ObservedObject private var speechManager = SpeechManager()

    @State private var consoleText: String = "Session started \(formattedDate())\n\n"
    @State private var circleColor: Color = .black

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            ConsoleView(consoleText: $consoleText)
            HStack{
                Circle()
                    .fill(circleColor)
                    .frame(width: 10, height: 10)
                    .padding()
                Button(action: {
                    if (!recorder.isRecording) {
                        circleColor = .red
                        recorder.startRecording()
                        self.recorder.setPlayAndRecord()
                    } else {
                        circleColor = .black
                        recorder.stopRecording()
                        self.recorder.setPlayback()
                    }
                })
                {
                    Text(!recorder.isRecording ? "Start Listening" : "Stop Listening")
                        .foregroundColor(colorScheme == .light ? Color.white : Color.black)
                        .padding()
                        .background(
                            (recorder.hasMicrophoneAccess && recorder.isSpeechRecognizerAvailable) ?
                            Color.primary :
                                Color.gray.opacity(0.6)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.2), lineWidth: 1)
                        )
                        .cornerRadius(10)
                }
                .contentShape(Rectangle())
                .disabled(
                    !recorder.hasMicrophoneAccess
                    || !recorder.isSpeechRecognizerAvailable
                )
                Button(action: {
                    self.consoleText = "Session started \(formattedDate())\n\n"
                })
                {
                    Text("Clear")
                        .foregroundColor(colorScheme == .light ? Color.white : Color.black)
                        .padding()
                        .background(Color.primary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.2), lineWidth: 1)
                        )
                        .cornerRadius(10)
                }
                .contentShape(Rectangle())
            }
        }
        .onAppear {
            self.recorder.onRecognisedText = { [self] text in
                if (text == "") {
                    return
                }

                if (UserDefaults.standard.bool(forKey: "SPEAK_TEXT")) {
                    self.recorder.pauseRecording()
                    self.recorder.setPlayback()
                    self.speechManager.speakText(text: text)
                }
                self.consoleText = self.consoleText + "\n" + text
            }
            self.recorder.onRecognisedSilence = { [self] seconds in
                self.circleColor = .green
            }
            self.recorder.onRecognisedSound = {
                self.circleColor = .red
            }
            self.speechManager.onFinishSpeaking = {
                self.recorder.resumeRecording()
                self.recorder.setPlayAndRecord()
            }
            
            self.recorder.requestPermission()
        }
        .alert(isPresented: $recorder.showAlert) {
             Alert(title: Text(recorder.alertTitle), message: Text(recorder.alertMessage), dismissButton: .default(Text("OK")))
         }
    }
}

struct ContentView_Previews: PreviewProvider {    
    static var previews: some View {
        ContentView()
     }
}

func formattedDate() -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter.string(from: Date())
}
