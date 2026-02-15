import SwiftUI

@available(iOS 17.0, *)
struct HomeView: View {
    var gameState: GameState
    @State private var showOnboarding = false
    @State private var showGame = false
    
    var body: some View {
            ScrollView {
                VStack(spacing: 0) {
                    
                    PointsWidget(score: gameState.totalScore)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                    
                    GameWidget(
                        title: "Road Trip",
                        imageName: "car",
                        onStartChallenge: {
                            if gameState.currentChallenge != nil {
                                showGame = true
                            } else {
                                showOnboarding = true
                            }
                        },
                        isContinuing: gameState.currentChallenge != nil
                    )
                    .padding(.horizontal, 20)
                    
                    HStack {
                        Text("At a Glance")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    
                    HStack(spacing: 20){
                        JourneyStatCardHome(
                            icon: "checkmark.circle.fill",
                            value: "\(gameState.collectedItems.count)",
                            label: "Objects Found",
                            color: .green
                        )
                        
                        JourneyStatCardHome(
                            icon: "flag.fill",
                            value: "\(gameState.completedChallengesCount)",
                            label: "Trips",
                            color: .green
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    
                    
                    
                    
                    
                    // Recent items header
                    HStack {
                        Text("Recent Finds")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 8)
                    
                    // LazyHGrid inside a horizontal ScrollView
                    if gameState.collectedItems.isEmpty {
                        HStack(spacing: 16) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 50))
                                .foregroundStyle(.secondary)
                            
                            VStack {
                                Text("No Items Collected Yet")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                                Text("Complete challenges to start your collection!")
                                    .font(.subheadline)
                                    .foregroundStyle(.tertiary)
                                    .multilineTextAlignment(.center)
                            }
                            
                            
                        }
                        .padding(.top, 40)
                        .padding(.horizontal, 40)
                        
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                ForEach(gameState.collectedItems.prefix(6), id: \.id) { item in
                                    RecentItemCard(item: item)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                        }
                    }
                    
                    Spacer()
                }
                
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Hey, Explorer!")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(isPresented: $showOnboarding) {
                OnboardingView(gameState: gameState, popToRoot: $showOnboarding)
            }
            .navigationDestination(isPresented: $showGame) {
                GameView(gameState: gameState, popToRoot: $showGame)
            }
    }
}

// MARK: - Recent Item Card
struct RecentItemCard: View {
    let item: CollectedItem
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let image = item.image {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
            }
            
            // Material overlay with object name
            VStack(alignment: .leading, spacing: 4) {
                Text(item.object.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                Text("\(item.object.points) pts")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .frame(width: 180, height: 240)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    }
}
// MARK: - Points Widget


struct PointsWidget: View {
    
    @State var score: Int
    
    var body: some View {
        HStack {
            ZStack{
                HStack{
                    ZStack{
                        Circle()
                            .foregroundStyle(Color.yellow.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "star.fill")
                            .foregroundStyle(Color.yellow)
                            .font(.system(size: 30))
                    }
                    
                    Spacer()
                }
                
                VStack{
                    Text("\(score)")
                        .font(.system(.title, design: .rounded))
                        .bold()
                    
                    Text("Total Points")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.secondary)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
        }
    }
}
// MARK: - Game Widget
struct GameWidget: View {
    var title: String
    var imageName: String
    var onStartChallenge: () -> Void
    var isContinuing: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 65, height: 70)
                    .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                    .padding()
                    .foregroundStyle(.indigo)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("CHALLENGE")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .tracking(1)
                    
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text("Find 6 objects in your route!")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .allowsTightening(true)
                }
                
                Spacer()
            }
            
            Button {
                onStartChallenge()
            } label: {
                Text(isContinuing ? "Continue Game" : "Start Challenge")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .buttonBorderShape(.capsule)
            .tint(isContinuing ? .green : .indigo)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

// MARK: - Journey Stat Card (Home View)

struct JourneyStatCardHome: View {
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
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Text(label)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

#Preview {
    NavigationStack {
        if #available(iOS 17.0, *) {
            HomeView(gameState: GameState())
        } else {
            Text("Unsupported iOS version")
        }
    }
}

