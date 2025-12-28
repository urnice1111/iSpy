import SwiftUI

@available(iOS 17.0, *)
struct GalleryView: View {
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
                
                if gameState.collectedItems.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 80))
                            .foregroundStyle(.white.opacity(0.7))
                        
                        Text("No Items Collected Yet")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        
                        Text("Complete challenges to start your collection!")
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 15),
                            GridItem(.flexible(), spacing: 15)
                        ], spacing: 15) {
                            ForEach(gameState.collectedItems) { item in
                                GalleryItemCard(item: item)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Gallery")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                gameState.loadState()
            }
        }
    }
}

struct GalleryItemCard: View {
    let item: CollectedItem
    
    var difficultyColor: Color {
        switch item.object.difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image
            ZStack {
                if let image = item.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                    
                    Image(systemName: "photo")
                        .font(.system(size: 40))
                        .foregroundStyle(.gray)
                }
            }
            .frame(height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Object info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.object.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                HStack {
                    Text(item.object.difficulty.rawValue.capitalized)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(difficultyColor)
                    
                    Text("•")
                        .foregroundStyle(.white.opacity(0.5))
                    
                    Text("\(item.object.points) pts")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                Text(item.timestamp, style: .date)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(.horizontal, 4)
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
        GalleryView()
    } else {
        // Fallback on earlier versions
    }
}

