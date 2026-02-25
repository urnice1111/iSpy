import SwiftUI

@available(iOS 17.0, *)
struct HomeView: View {
        
    @State private var showOnboarding = false
    @State private var showGame = false
    @Environment(GameState.self) var gameState

    private var hasActiveGame: Bool {
        guard let challenge = gameState.currentChallenge else { return false }
        return !challenge.isExpired && !challenge.isCompleted
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Image("MainBackground")
                    .resizable()
                    .ignoresSafeArea()
                
                CloudFieldView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                
                VStack(spacing: 30) {
                    Text("Hey, Explorer!")
                        .font(.custom("FredokaOne-Regular", size: 100))
                        .foregroundStyle(Color("Title"))
                        .shadow(color: .black.opacity(0.15), radius: 2, y: 2)
                        .padding(.top, 16)
                        .padding(.bottom, 50)
                    
                    HStack(alignment: .top, spacing: 24) {
                        
                        PointsWidget(score: gameState.totalScore)
                            .frame(maxWidth: 280)
                        
                        VStack(spacing: 8) {
                            Image("RoadTrip")
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(radius: 10)
                            
                            Button {
                                if hasActiveGame {
                                    showGame = true
                                } else {
                                    showOnboarding = true
                                }
                            } label: {
                                Text(hasActiveGame ? "Continue adventure!" : "Start adventure!")
                                    .font(.custom("FredokaOne-Regular", size: 22))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 12)
                                    .background(Capsule().fill(Color.orange))
                                    .shadow(color: .orange.opacity(0.4), radius: 6, y: 4)
                            }
                            .padding(.top, 4)
                        }
                        .frame(maxWidth: 400)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("At a glance")
                                .font(.custom("FredokaOne-Regular", size: 40))
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.15), radius: 2, y: 2)
                            
                            HStack(spacing: 12) {
                                StatsWidget(
                                    value: "\(gameState.collectedItems.count)",
                                    label: "Founded",
                                    icon: "checkmark"
                                )
                                
                                StatsWidget(
                                    value: "\(gameState.completedChallengesCount)",
                                    label: "Trips",
                                    icon: "flag"
                                )
                            }
                            
                            Text("Recent Finds")
                                .font(.custom("FredokaOne-Regular", size: 40))
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.15), radius: 2, y: 2)
                            
                            Spacer()
                        }
                        .frame(maxWidth: 320)
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
            }
            .navigationDestination(isPresented: $showOnboarding) {
                OnboardingView(gameState: gameState, popToRoot: $showOnboarding)
            }
            .navigationDestination(isPresented: $showGame) {
                GameView(gameState: gameState, popToRoot: $showGame)
            }
        }
    }
}

// MARK: - Clouds

private struct CloudConfig: Identifiable {
    let id: Int
    let size: CGFloat
    let yFraction: CGFloat
    let duration: Double
    let phase: Double
    let opacity: Double
}

private let cloudConfigs: [CloudConfig] = [
    CloudConfig(id: 0, size: 260, yFraction: 0.04, duration: 50, phase: 0.10, opacity: 0.95),
    CloudConfig(id: 1, size: 100, yFraction: 0.18, duration: 62, phase: 0.55, opacity: 0.45),
    CloudConfig(id: 2, size: 180, yFraction: 0.10, duration: 44, phase: 0.75, opacity: 0.80),
    CloudConfig(id: 3, size: 70,  yFraction: 0.30, duration: 70, phase: 0.30, opacity: 0.35),
    CloudConfig(id: 4, size: 140, yFraction: 0.22, duration: 38, phase: 0.90, opacity: 0.65),
    CloudConfig(id: 5, size: 220, yFraction: 0.07, duration: 56, phase: 0.45, opacity: 0.85),
    CloudConfig(id: 6, size: 50,  yFraction: 0.35, duration: 76, phase: 0.15, opacity: 0.30),
    CloudConfig(id: 7, size: 160, yFraction: 0.14, duration: 42, phase: 0.65, opacity: 0.70),
]

struct CloudFieldView: View {
    @State private var startDate = Date.now

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { context in
                let elapsed = context.date.timeIntervalSince(startDate)
                Canvas { gfxContext, canvasSize in
                    for cloud in cloudConfigs {
                        let totalTravel = canvasSize.width + cloud.size
                        let progress = ((elapsed / cloud.duration) + cloud.phase).truncatingRemainder(dividingBy: 1.0)
                        let x = -cloud.size / 2 + CGFloat(progress) * totalTravel
                        let y = canvasSize.height * cloud.yFraction

                        if let resolved = gfxContext.resolveSymbol(id: cloud.id) {
                            gfxContext.drawLayer { ctx in
                                ctx.opacity = cloud.opacity
                                ctx.draw(resolved, at: CGPoint(x: x, y: y))
                            }
                        }
                    }
                } symbols: {
                    ForEach(cloudConfigs) { cloud in
                        Image("Nube")
                            .resizable()
                            .scaledToFit()
                            .frame(width: cloud.size)
                            .tag(cloud.id)
                    }
                }
            }
        }
    }
}

// MARK: - Adventure Card

struct AdventureCard: View {
    var body: some View {
        
    }
}

// MARK: - Points Widget

struct PointsWidget: View {
    var score: Int
    
    var body: some View {
        HStack(spacing: 8) {
            Image("Star")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            
            VStack(spacing: 2) {
                Text("\(score)")
                    .font(.custom("FredokaOne-Regular", size: 52))
                    .foregroundStyle(.black)
                Text("Points")
                    .font(.custom("FredokaOne-Regular", size: 28))
                    .foregroundStyle(Color("StatsText"))
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("ColorOffset"))
                    .shadow(color: .black.opacity(0.4), radius: 6, y: 3)
                    .offset(y: 5)
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.4), radius: 6, y: 3)
            }
        )
    }
}

struct StatsWidget: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            
            Text(value)
                .font(.custom("FredokaOne-Regular", size: 36))
                .foregroundStyle(.black)
            
            Text(label)
                .font(.custom("FredokaOne-Regular", size: 14))
                .foregroundStyle(Color("StatsText"))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 140, maxHeight: 140)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("ColorOffset"))
                    .shadow(color: .black.opacity(0.4), radius: 6, y: 3)
                    .offset(y: 5)
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.4), radius: 6, y: 3)
            }
        )
    }
}
