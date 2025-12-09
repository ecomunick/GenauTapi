import SwiftUI

struct ConsoleView: View {
    @Binding var consoleText: String

    var body: some View {
        GeometryReader { geometry in
            VStack {
                ScrollView {
                    Text(consoleText)
                        .textSelection(.enabled)
                }
                .frame(width: geometry.size.width, alignment: .leading)
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
            }
        }
    }
}

struct ConsoleView_Previews: PreviewProvider {
    static var previewText = "Here you can place the program's input and output."
    
    static var previews: some View {
        ConsoleView(consoleText: .constant(previewText))
    }
}
