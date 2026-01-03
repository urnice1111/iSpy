import SwiftUI

@available(iOS 17.0, *)
struct HomeView: View {
    var gameState: GameState
    @State private var showOnboarding = false
    @State private var showGame = false
    
    
    var body: some View {
        VStack {
            HStack {
                Text("\(gameState.totalScore)")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundStyle(.black)
                
                Text("Points")
                    .font(.system(size: 35))
                    .foregroundStyle(.black)
                
                Spacer()
            }
            //            .padding(.top, 20)
            .padding(.horizontal, 20)
            
            GameWidget(
                title: "Road Trip",
                imageName: "roadTrip",
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
            
            // Recent items header
            HStack {
                Text("Recent Finds")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.black)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            // LazyHGrid inside a horizontal ScrollView
            if gameState.collectedItems.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 50))
                        .foregroundStyle(.black.opacity(0.7))
                    
                    Text("No Items Collected Yet")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.black.opacity(0.7))
                    
                    //                    Text("Complete challenges to start your collection!")
                    //                        .font(.body)
                    //                        .foregroundStyle(.white.opacity(0.8))
                    //                        .multilineTextAlignment(.center)
                    //                        .padding(.horizontal)
                }.padding(.top, 40)
                
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Rectangle()
                .fill(Color("BackgroundColor"))
                .scaledToFill()
                .ignoresSafeArea()
        )
        .navigationTitle("Hey, Explorer!")
        .toolbarColorScheme(.light, for: .navigationBar) // makes title/items dark (black)
        .toolbarBackground(Color("BackgroundColor"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationDestination(isPresented: $showOnboarding) {
            OnboardingView(gameState: gameState)
        }
        .navigationDestination(isPresented: $showGame) {
            GameView(gameState: gameState)
        }
        
    }
}

// Simple card for a recent item (customize to your model)
struct RecentItemCard: View {
    let item: CollectedItem
    
    var body: some View {
        ZStack {
            if let image = item.image {
                image
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: 180, height: 240)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        
        
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
                        .foregroundStyle(.black)
                        .textCase(.uppercase)
                    
                    Text(title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.leading)
                    
                    Text("Find 6 objects in your route!")
                        .font(.body)
                        .foregroundStyle(.black)
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
                        .background(Color("ButtonColor"))
                        .clipShape(Capsule())
                        .shadow(radius: 5)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color("WidgetColor"))
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    if #available(iOS 17.0, *) {
        HomeView(gameState: GameState())
    } else {
        // Fallback on earlier versions
        Text("Unsupported iOS version")
    }
}
