import SwiftUI

@available(iOS 17.0, *)
struct HomeView: View {
    
    @State private var showOnboarding = false
    @State private var gameState = GameState()
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
                    
                    HStack(alignment: .top, spacing: 24) {
                        
                        PointsWidget()
                            .frame(maxWidth: 280)
                        
                        
                        VStack(spacing: 8) {
                            Image("RoadTrip")
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(radius: 10)
                            
                            Button {
                                showOnboarding = true
                            } label: {
                                Text("Start adventure!")
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
                        
                        // Placeholder for future widgets (At a Glance, Recent Finds)
                        Color.clear
                            .frame(maxWidth: 280)
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
            }
            .navigationDestination(isPresented: $showOnboarding) {
                OnboardingView(gameState: gameState, popToRoot: $showOnboarding)
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
    var body: some View {
        HStack(spacing: 8) {
            Image("Star")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            
            VStack(spacing: 2) {
                Text("430")
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
            ZStack{
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("ColorOffset"))
                    .shadow(color: .black.opacity(0.4), radius: 6, y: 3)
                    .offset(y:5)
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.4), radius: 6, y: 3)
                
                
            }
            
        )
        
    }
}
