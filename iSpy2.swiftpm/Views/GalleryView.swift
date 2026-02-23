//
//  GalleryView.swift
//  iSpy
//
//  Created by UwU on 22/02/26.
//

import SwiftUI

@available(iOS 17.0, *)
struct GalleryView: View {
    @Environment(GameState.self) var gameState
    let cards = Array(1...20)
    
    // 1. EL TRUCO DEL GRID: Usar .flexible con un rango en lugar de .fixed
    // Intentará medir 320, pero en iPads más pequeños se encogerá (hasta 220) para caber sin empalmarse.
    var body: some View {
        GeometryReader { geo in
            let topPadding: CGFloat = 20
            let bottomPadding: CGFloat = 16
            let availableHeight = geo.size.height + geo.safeAreaInsets.top
            let titleFont = min(availableHeight * 0.08, 70)
            let titleArea = titleFont + 12
            let gridSpacing: CGFloat = 16
            let computedHeight = (availableHeight - titleArea - gridSpacing - topPadding - bottomPadding) / 2
            let cardHeight = min(computedHeight, 260)
            let gridRows = [
                GridItem(.fixed(cardHeight), spacing: gridSpacing),
                GridItem(.fixed(cardHeight), spacing: gridSpacing)
            ]
            
            ZStack {
                Image("BackgroundOnboarding")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Text("Treasure Gallery")
                        .font(.custom("FredokaOne-Regular", size: titleFont))
                        .foregroundStyle(Color("Title"))
                        .shadow(color: .black.opacity(0.15), radius: 2, y: 2)
                        .lineLimit(1)
                        .minimumScaleFactor(0.4)
                        .padding(.horizontal, 40)
                        .frame(height: titleArea)
                        
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: gridRows, spacing: gridSpacing) {
                            ForEach(gameState.collectedItems, id: \.id) { item in
                                NavigationLink(destination: ObjectDetailView(collectedItem: item)) {
                                    ObjectCardView(object: item)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                    }
                }
                .padding(.top, topPadding)
            }
            .ignoresSafeArea(edges: .top)
        }
    }
}

struct ObjectCardView: View {
    private static let cardColors: [(Color, Color)] = [
        (Color(red: 0.85, green: 0.15, blue: 0.15), Color(red: 0.7, green: 0.1, blue: 0.1)),
        (Color(red: 0.2, green: 0.5, blue: 0.85),  Color(red: 0.12, green: 0.35, blue: 0.7)),
        (Color(red: 0.15, green: 0.7, blue: 0.4),   Color(red: 0.1, green: 0.55, blue: 0.3)),
        (Color(red: 0.9, green: 0.55, blue: 0.1),   Color(red: 0.75, green: 0.4, blue: 0.05)),
        (Color(red: 0.6, green: 0.3, blue: 0.8),    Color(red: 0.45, green: 0.2, blue: 0.65)),
    ]
    
    var object: CollectedItem
    let cardColor: (Color, Color)
    
    init(object: CollectedItem) {
        self.object = object
        self.cardColor = Self.cardColors[abs(object.id.hashValue) % Self.cardColors.count]
    }
    
    var dif: String {
        switch object.object.difficulty {
        case .easy:
            return "Easy"
        case .medium:
            return "Medium"
        case .hard:
            return "Hard"
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            let cardWidth = geo.size.width
            let imageHeight = geo.size.height * 0.58
            
            VStack(spacing: 0) {
                Image(object.object.imageName)
                    .resizable()
                    .scaledToFit()
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .frame(height: imageHeight)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: cardWidth * 0.1))
                    .padding(.horizontal, 10)
                    .padding(.top, 10)
                
                Spacer(minLength: 4)
                
                VStack(spacing: 6) {
                    Text(object.object.name)
                        .font(.custom("FredokaOne-Regular", size: cardWidth * 0.09))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    
                    HStack(spacing: 6) {
                        Text(dif)
                            .font(.custom("FredokaOne-Regular", size: cardWidth * 0.075))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 3)
                            .background(dif == "Easy" ? Color.green : (dif == "Medium" ? Color.orange : Color.red))
                            .clipShape(Capsule())
                        
                        Image("Star")
                            .resizable()
                            .scaledToFit()
                            .frame(height: cardWidth * 0.1)
                        
                        Text("\(object.object.points)")
                            .font(.custom("FredokaOne-Regular", size: cardWidth * 0.09))
                            .foregroundStyle(.yellow)
                    }
                }
                .padding(.horizontal, 8)
                
                Spacer(minLength: 8)
            }
            .frame(width: cardWidth, height: geo.size.height-30)
            .background(
                LinearGradient(
                    colors: [cardColor.0, cardColor.1],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: cardWidth * 0.12))
        }
        .aspectRatio(0.72, contentMode: .fit)
    }
}

//#Preview {
//    
//        GalleryView(gameS)
//
//}

