import SwiftUI

@available(iOS 17.0, *)
struct HomeView: View {
    var gameState: GameState
    @State private var showOnboarding = false
    @State  var showGame = false  // NUEVO
    
    var body: some View {
        VStack {
            HStack {
                Text("\(gameState.totalScore)")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("Points")
                    .font(.system(size: 35))
                    .foregroundStyle(.white)
                
                Spacer()
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
 
            GameWidget(
                title: "Road Trip",
                imageName: "roadTrip",
                onStartChallenge: {
                    if gameState.currentChallenge != nil {
                        showGame = true
                    } else {showOnboarding = true}
                },
                isContinuing: gameState.currentChallenge != nil
            )
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image("backgroundPhoto")
                .resizable()
                .scaledToFill()
                .overlay(Color.black.opacity(0.25))
                .ignoresSafeArea()
                .blur(radius: 13)
        )
        .navigationTitle("Hey, Explorer!")
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationDestination(isPresented: $showOnboarding) {
            OnboardingView(gameState: gameState)
        }
        .navigationDestination(isPresented: $showGame) {GameView(gameState: gameState)}
        .onAppear {
            gameState.loadState()
        }
    }
}
struct GameWidget: View {
    var title: String
    var imageName: String
    var onStartChallenge: () -> Void
    var isContinuing: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            
            HStack(spacing: 15) {
                
                Spacer()
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .shadow(radius: 5)
                
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text("Challenge:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    
                    Text(title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.leading)
                    
                    Text("Find 6 objects in your route!")
                        .font(.body)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
            
            Button {
                onStartChallenge()
            } label: {
                if isContinuing {
                    Text("Continue game")
                        .font(.title3)
                        .bold()
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(Color.green)
                        .clipShape(Capsule())
                        .shadow(radius: 5)
                    
                } else {
                    Text("Start Challenge!")
                        .font(.title3)
                        .bold()
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(Color.blue)
                        .clipShape(Capsule())
                        .shadow(radius: 5)
                    
                }
                
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    if #available(iOS 17.0, *) {
        HomeView(gameState: GameState())
    } else {
        // Fallback on earlier versions
    }
}
