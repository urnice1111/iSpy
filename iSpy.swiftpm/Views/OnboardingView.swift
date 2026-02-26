import SwiftUI

@available(iOS 17.0, *)
struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentPage = 0
    @State private var selectedObjects: [GameObject] = []
    @Binding var popToRoot: Bool
    var gameState: GameState
    init(gameState: GameState, popToRoot: Binding<Bool>) {
        self.gameState = gameState
        self._popToRoot = popToRoot
        _selectedObjects = State(initialValue: ObjectDatabase.getRandomObjects())
    }
    
    var body: some View {
        ZStack {
            
            Image("BackgroundOnboarding")
                .resizable()
                .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                // How to play
                InstructionsSlide()
                    .tag(0)
                
                
                // Objects to find
                ObjectsSlide(objects: selectedObjects, gameState: gameState, popToRoot: $popToRoot)
                    .tag(1)

            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}

// MARK: - Instructions Slide
struct InstructionsSlide: View {
    var body: some View {
        GeometryReader { geo in
            let h = geo.size.height
            let w = geo.size.width
            
            // This scale was gotten from testing on canvas with a big iPad, and then test in my mini iPad
            let scale = min(w / 1200, h / 900)
            
            VStack(spacing: 24 * scale) {
                Spacer()
                
                Text("How to play!")
                    .font(.custom("FredokaOne-Regular", size: 130 * scale))
                    .foregroundStyle(Color("Title"))
                    .shadow(color: .black.opacity(0.15), radius: 2, y: 2)
                    .padding(.top, 16 * scale)
                    .padding(.bottom, 60 * scale)
                
                VStack(spacing: 22 * scale) {
                    InstructionRow(text: "Find 6 fun objects on your trip!", icon: "magnifier_icon", scale: scale)
                    InstructionRow(text: "Snap photos of them!", icon: "camera_icon", scale: scale)
                    InstructionRow(text: "Finish in 30 minutes!", icon: "clock_icon", scale: scale)
                    InstructionRow(text: "Earn stars for each one!", icon: "Star", scale: scale)
                }
                .padding(30 * scale)
                .frame(maxWidth: 1000 * scale, alignment: .center)
                .padding(.horizontal, 50)
                .background(
                    RoundedRectangle(cornerRadius: 40 * scale)
                        .fill(.white)
                )
                
                Spacer()
                
                HStack(spacing: 6) {
                    Text("Swipe to continue")
                        .font(.custom("FredokaOne-Regular", size: 50 * scale))
                        .foregroundStyle(Color("StatsText"))
                    Image(systemName: "chevron.right")
                        .font(.custom("FredokaOne-Regular", size: 20 * scale))
                        .foregroundStyle(Color("StatsText"))
                }
                .padding(.bottom, 40 * scale)
            }
            .frame(width: w, height: h)
        }
    }
}

// MARK: - Instruction Row
struct InstructionRow: View {
    let text: String
    let icon: String
    var scale: CGFloat
    
    var body: some View {
        HStack(alignment: .center, spacing: 36 * scale) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 70 * scale, height: 70 * scale)
                .frame(width: 70 * scale, alignment: .leading)
            
            Text(text)
                .font(.custom("FredokaOne-Regular", size: 50 * scale))
                .foregroundStyle(Color("StatsText"))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Objects Slide
@available(iOS 17.0, *)
struct ObjectsSlide: View {
    let objects: [GameObject]
    let gameState: GameState
    @State private var navigateToGame = false
    @Environment(\.dismiss) var dismiss
    @Binding var popToRoot: Bool

    var body: some View {
        GeometryReader { geo in
            let h = geo.size.height
            let w = geo.size.width
            let scale = min(w / 1200, h / 900)

            let columns = [
                GridItem(.flexible(), spacing: 14 * scale),
                GridItem(.flexible(), spacing: 14 * scale)
            ]

            VStack(spacing: 16 * scale) {
                VStack(spacing: 2 * scale) {
                    Text("Your Mission")
                        .font(.custom("FredokaOne-Regular", size: 100 * scale))
                        .foregroundStyle(Color("Title"))
                        .shadow(color: .black.opacity(0.15), radius: 2, y: 2)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)

                    Text("Find these \(objects.count) objects")
                        .font(.custom("FredokaOne-Regular", size: 40 * scale))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                .padding(.vertical, 70 * scale)
                

                LazyVGrid(columns: columns, spacing: 12 * scale) {
                    ForEach(objects, id: \.self) { object in
                        ObjectCard(object: object, scale: scale)
                    }
                }
                .frame(maxWidth: 900 * scale)

                Spacer()

                Button {
                    gameState.startChallenge(objects: objects)
                    navigateToGame = true
                } label: {
                    HStack(spacing: 8) {
                        Text("Start Adventure!")
                            .font(.custom("FredokaOne-Regular", size: 28 * scale))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 18 * scale, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 40 * scale)
                    .padding(.vertical, 14 * scale)
                    .background(Capsule().fill(Color.orange))
                    .shadow(color: .orange.opacity(0.4), radius: 6, y: 4)
                }
                .padding(.bottom, 50 * scale)
            }
            .frame(width: w, height: h)
            .navigationDestination(isPresented: $navigateToGame) {
                GameView(gameState: gameState, popToRoot: $popToRoot)
            }
        }
    }
}

// MARK: - Object Card
struct ObjectCard: View {
    let object: GameObject
    var scale: CGFloat = 1.0

    var difficultyColor: Color {
        switch object.difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }

    var body: some View {
        HStack(spacing: 12 * scale) {
            Group {
                Image(object.imageName)
                    .resizable()
            }
            .scaledToFit()
            .frame(width: 100 * scale, height: 100 * scale)

            VStack(alignment: .leading, spacing: 3 * scale) {
                Text(object.name)
                    .font(.custom("FredokaOne-Regular", size: 28 * scale))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                HStack(spacing: 6 * scale) {
                    Text(object.difficulty.rawValue.capitalized)
                        .font(.custom("FredokaOne-Regular", size: 28 * scale))
                        .font(.system(size: 20 * scale, weight: .semibold))
                        .foregroundStyle(difficultyColor)
                        .padding(.horizontal, 8 * scale)
                        .padding(.vertical, 2 * scale)
                        .background(difficultyColor.opacity(0.15))
                        .clipShape(Capsule())

                    Image("Star")
                        .resizable()
                        .frame(width: 30 * scale, height: 30 * scale)
         
                    Text("\(object.points)")
                        .font(.custom("FredokaOne-Regular", size: 30 * scale))
                        .foregroundStyle(Color("StatsText"))
                }
            }

            Spacer(minLength: 0)


        }
        .padding(.horizontal, 14 * scale)
        .padding(.vertical, 12 * scale)
        .background(
            RoundedRectangle(cornerRadius: 18 * scale)
                .fill(.white)
                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        )
    }
}


