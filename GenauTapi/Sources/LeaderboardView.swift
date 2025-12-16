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
