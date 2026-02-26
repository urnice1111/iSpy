import SwiftUI
import TipKit

@available(iOS 17.0, *)
struct StartAdventureTip: Tip {
    static let aboutDismissed = Event(id: "aboutDismissed")
    
    var title: Text {
        Text("Start Your First Adventure!")
    }
    
    var message: Text? {
        Text("Tap here to begin a new mission and find hidden objects on your trip!")
    }
    
    var image: Image? {
        Image(systemName: "map.fill")
    }
    
    var rules: [Rule] {
        #Rule(Self.aboutDismissed) { $0.donations.count >= 1 }
    }
}

@available(iOS 17.0, *)
struct HomeView: View {
        
    @State private var showOnboarding = false
    @State private var showGame = false
    @Environment(GameState.self) var gameState
    private let adventureTip = StartAdventureTip()

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
                
                VStack(spacing: 30) {
                    Text("Hey, Explorer!")
                        .font(.custom("FredokaOne-Regular", size: 100))
                        .foregroundStyle(Color("Title"))
                        .shadow(color: .black.opacity(0.15), radius: 2, y: 2)
                        .padding(.top, 16)
                        .padding(.bottom, 50)
                    
                    HStack(alignment: .top, spacing: 24) {
                        
                        VStack(spacing: 16) {
                            PointsWidget(score: gameState.totalScore)
                            AboutWidget()
                        }
                        .frame(maxWidth: 280)
                        
                        Button {
                            if hasActiveGame {
                                showGame = true
                            } else {
                                showOnboarding = true
                            }
                        } label: {
                            ZStack(alignment: .bottom) {
                                Image(hasActiveGame ? "road_trip_continue" : "road_trip_start")
                                    .resizable()
                                    .scaledToFit()


                            }
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(radius: 10)
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: 400)
                        .popoverTip(adventureTip, arrowEdge: .leading)
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
            }
            .navigationDestination(isPresented: $showOnboarding) {
                OnboardingView(gameState: gameState, popToRoot: $showOnboarding)
                    .toolbar(.hidden, for: .tabBar)
            }
            .navigationDestination(isPresented: $showGame) {
                GameView(gameState: gameState, popToRoot: $showGame)
                    .toolbar(.hidden, for: .tabBar)
            }
        }
    }
}

// MARK: - About Widget

struct AboutWidget: View {
    @State private var showAbout = false
    
    var body: some View {
        Button { showAbout = true } label: {
            HStack(spacing: 8) {
                Image("profile_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                
                Text("About")
                    .font(.custom("FredokaOne-Regular", size: 36))
                    .foregroundStyle(.black)
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
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
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

