import SwiftUI

@available(iOS 17.0, *)
struct ProfileView: View {
    var gameState: GameState
    @State var showingResetGameAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile header
                    VStack() {
                        // Avatar with gradient ring
                        Image("memoji2")
                            .resizable()
                            .frame(width: 150, height: 150)
                            .scaledToFit()
                        
                        
                        VStack(spacing: 4) {
                            Text("Explorer")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                            
                            Text("Road Trip Champion")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    
                    // Statistics Widget
                    StatisticsWidget(gameState: gameState)
                        .padding(.horizontal, 20)
                    
                    // Achievements section placeholder
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "trophy.fill")
                                .font(.title2)
                                .foregroundStyle(.orange)
                            Text("Your Journey")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                        }
                        
                        // Journey stats
                        HStack(spacing: 12) {
                            JourneyStatCard(
                                icon: "camera.fill",
                                value: "\(gameState.collectedItems.count)",
                                label: "Photos",
                                color: .blue
                            )
                            
                            JourneyStatCard(
                                icon: "star.fill",
                                value: "\(gameState.totalScore)",
                                label: "Points",
                                color: .orange
                            )
                            
                            JourneyStatCard(
                                icon: "flag.fill",
                                value: "\(gameState.completedChallengesCount)",
                                label: "Trips",
                                color: .green
                            )
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color("WidgetColor").opacity(0.5))
                            )
                    )
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
                    
                    // Reset button - Apple destructive style
                    Button {
                        showingResetGameAlert = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset Progress")
                        }
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red.opacity(0.1))
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .background(Color("BackgroundColor"))
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .scrollContentBackground(.hidden)
        }
        .alert("Reset progress?",
               isPresented: $showingResetGameAlert
        ) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                gameState.resetGame()
            }
        } message: {
            Text("You will lose all your data and start over from the beginning.")
        }
        .tint(nil)
    }
}

// MARK: - Statistics Widget
@available(iOS 17.0, *)
struct StatisticsWidget: View {
    let gameState: GameState
    
    var body: some View {
        HStack(spacing: 0) {
            StatItem(
                value: "\(gameState.totalScore)",
                label: "Total Points",
                icon: "star.fill",
                color: .orange
            )
            
            Divider()
                .frame(height: 40)
                .background(Color.secondary.opacity(0.3))
            
            StatItem(
                value: "\(gameState.collectedItems.count)",
                label: "Objects Found",
                icon: "checkmark.circle.fill",
                color: .green
            )
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("WidgetColor").opacity(0.5))
                )
        )
        .shadow(color: .black.opacity(0.08), radius: 12, y: 6)
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Journey Stat Card
struct JourneyStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

#Preview {
    if #available(iOS 17.0, *) {
        ProfileView(gameState: GameState())
    } else {
        // Fallback on earlier versions
    }
}
