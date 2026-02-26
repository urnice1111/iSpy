//
//  GalleryView.swift
//  iSpy
//
//  Created by UwU on 22/02/26.
//

import SwiftUI

@available(iOS 26.0, *)
struct GalleryView: View {
    @Environment(GameState.self) var gameState

    private var groupedItems: [(challengeId: UUID, items: [CollectedItem])] {
        let grouped = Dictionary(grouping: gameState.collectedItems, by: \.challengeId)
        return grouped
            .map { (challengeId: $0.key, items: $0.value.sorted { $0.timestamp < $1.timestamp }) }
            .sorted { ($0.items.first?.timestamp ?? .distantPast) > ($1.items.first?.timestamp ?? .distantPast) }
    }

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
//                    Text("Treasure Gallery")
//                        .font(.custom("FredokaOne-Regular", size: titleFont))
//                        .foregroundStyle(Color("Title"))
//                        .shadow(color: .black.opacity(0.15), radius: 2, y: 2)
//                        .lineLimit(1)
//                        .minimumScaleFactor(0.4)
//                        .padding(.horizontal, 40)
//                        .frame(height: titleArea)
                    if gameState.collectedItems.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image("Star")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 90, height: 90)
                                .opacity(0.85)
                            
                            Text("Your gallery is empty!")
                                .font(.custom("FredokaOne-Regular", size: 32))
                                .foregroundStyle(.white)
                            
                            Text("Start your first adventure to discover\nand collect hidden treasures!")
                                .font(.custom("FredokaOne-Regular", size: 18))
                                .foregroundStyle(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .padding(40)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.black.opacity(0.25))
                        )
                        Spacer()
                    } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(Array(groupedItems.enumerated()), id: \.element.challengeId) { index, group in
                                ChallengeGroupView(
                                    challengeId: group.challengeId,
                                    items: group.items,
                                    defaultTitle: "Adventure \(groupedItems.count - index)",
                                    gridRows: gridRows,
                                    gridSpacing: gridSpacing,
                                    cardHeight: cardHeight
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                    }
                    }
                }
                .padding(.top, topPadding)
            }
            .ignoresSafeArea(edges: .top)
        }
    }
}

@available(iOS 26.0, *)
struct ChallengeGroupView: View {
    @Environment(GameState.self) var gameState
    let challengeId: UUID
    let items: [CollectedItem]
    let defaultTitle: String
    let gridRows: [GridItem]
    let gridSpacing: CGFloat
    let cardHeight: CGFloat

    @State private var isEditing = false
    @FocusState private var titleFocused: Bool

    private var titleBinding: Binding<String> {
        Binding(
            get: { gameState.challengeTitles[challengeId.uuidString] ?? defaultTitle },
            set: { gameState.challengeTitles[challengeId.uuidString] = $0 }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                if isEditing {
                    TextField("Title", text: titleBinding)
                        .font(.custom("FredokaOne-Regular", size: 22))
                        .foregroundStyle(.white)
                        .focused($titleFocused)
                        .onSubmit { commitTitle() }
                        .onChange(of: titleFocused) { _, focused in
                            if !focused { commitTitle() }
                        }
                } else {
                    Text(titleBinding.wrappedValue)
                        .font(.custom("FredokaOne-Regular", size: 22))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }

                Button {
                    if isEditing {
                        commitTitle()
                    } else {
                        isEditing = true
                        titleFocused = true
                    }
                } label: {
                    Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.white.opacity(0.7))
                }

                Spacer()
            }
            .padding(.horizontal, 4)

            LazyHGrid(rows: gridRows, spacing: gridSpacing) {
                ForEach(items, id: \.id) { item in
                    NavigationLink(destination: ObjectDetailView(collectedItem: item)) {
                        ObjectCardView(object: item)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
        )
    }

    private func commitTitle() {
        isEditing = false
        titleFocused = false
        gameState.saveState()
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

#Preview {
    if #available(iOS 26.0, *) {
        let state: GameState = {
            let s = GameState()
            let allObjects = ObjectDatabase.allObjects
            let challenge1 = UUID()
            let challenge2 = UUID()
            let challenge3 = UUID()
            let split1 = allObjects.prefix(4)
            let split2 = allObjects.dropFirst(4).prefix(3)
            let split3 = allObjects.dropFirst(7)
            s.collectedItems =
                split1.map { CollectedItem(object: $0, challengeId: challenge1) } +
                split2.map { CollectedItem(object: $0, challengeId: challenge2) } +
                split3.map { CollectedItem(object: $0, challengeId: challenge3) }
            s.challengeTitles[challenge1.uuidString] = "Road Trip"
            s.challengeTitles[challenge2.uuidString] = "City Walk"
            return s
        }()

        NavigationStack {
            GalleryView()
        }
        .environment(state)
    } else {
        EmptyView()
    }
}

