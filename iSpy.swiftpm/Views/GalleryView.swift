import SwiftUI

@available(iOS 17.0, *)
struct GalleryView: View {
    var gameState: GameState
    
    var body: some View {
        NavigationStack {
            Group {
                if gameState.collectedItems.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(Color.secondary.opacity(0.1))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 50))
                                .foregroundStyle(.secondary)
                        }
                        
                        VStack(spacing: 8) {
                            Text("No Items Collected Yet")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                            
                            Text("Complete challenges to start your collection!")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        
                        HStack{
                            Text("\(gameState.collectedItems.count) objects found")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(gameState.collectedItems) { item in
                                NavigationLink {
                                    // Navigate to detail view based on iOS version
                                    if #available(iOS 26.0, *) {
                                        ItemDetailView(item: item, gameState: gameState)
                                    } else {
                                        ItemDetailViewFallback(item: item)
                                    }
                                } label: {
                                    GalleryItemCard(item: item)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Gallery")
            .navigationBarTitleDisplayMode(.large)
            .scrollContentBackground(.hidden)
        }
    }
}

// MARK: - Gallery Item Card
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
        VStack(alignment: .leading, spacing: 12) {
            // Image
            ZStack {
                if let image = item.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                    
                    Image(systemName: "photo")
                        .font(.system(size: 36))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Object info
            VStack(alignment: .leading, spacing: 6) {
                Text(item.object.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    // Difficulty badge
                    Text(item.object.difficulty.rawValue.capitalized)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(difficultyColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(difficultyColor.opacity(0.15))
                        .clipShape(Capsule())
                    
                    // Points
                    Label("\(item.object.points)", systemImage: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
                
                Text(item.timestamp, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

#Preview {
    if #available(iOS 17.0, *) {
        GalleryView(gameState: GameState())
    } else {
        // Fallback on earlier versions
    }
}
