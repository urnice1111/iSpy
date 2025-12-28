import SwiftUI

@available(iOS 17.0, *)
struct ProfileView: View {
    var gameState: GameState
    
    init(gameState: GameState = GameState()) {
        self.gameState = gameState
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background matching app theme
                Image("backgroundPhoto")
                    .resizable()
                    .scaledToFill()
                    .overlay(Color.black.opacity(0.25))
                    .ignoresSafeArea()
                    .blur(radius: 13)
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Profile header
                        VStack(spacing: 15) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 100))
                                .foregroundStyle(.white)
                            
                            Text("Explorer")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .padding(.top, 40)
                        
                        // Score card
                        VStack(spacing: 20) {
                            Text("Total Score")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white.opacity(0.8))
                            
                            Text("\(gameState.totalScore)")
                                .font(.system(size: 60, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.1))
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.ultraThinMaterial)
                                )
                        )
                        .padding(.horizontal)
                        
                        // Statistics
                        VStack(spacing: 20) {
                            StatRow(
                                icon: "checkmark.circle.fill",
                                label: "Challenges Completed",
                                value: "\(gameState.completedChallengesCount)",
                                color: .green
                            )
                            
                            StatRow(
                                icon: "photo.fill",
                                label: "Items Collected",
                                value: "\(gameState.collectedItems.count)",
                                color: .blue
                            )
                        }
                        .padding(.horizontal)
                        
                        // Reset button (optional)
                        Button {
                            gameState.resetGame()
                        } label: {
                            Text("Reset Game")
                                .font(.body)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.1))
                                )
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Profile")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                gameState.loadState()
            }
        }
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color)
                .frame(width: 40)
            
            Text(label)
                .font(.system(size: 18))
                .foregroundStyle(.white)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.1))
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.ultraThinMaterial)
                )
        )
    }
}

#Preview {
    if #available(iOS 17.0, *) {
        ProfileView()
    } else {
        // Fallback on earlier versions
    }
}

