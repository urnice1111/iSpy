import SwiftUI

@available(iOS 17.0, *)
struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentPage = 0
    @State private var selectedObjects: [GameObject] = []
    var gameState: GameState
    var isGamePlaying: Bool = false
    
    init(gameState: GameState) {
        self.gameState = gameState
        _selectedObjects = State(initialValue: ObjectDatabase.getRandomObjects())
    }
    
    var body: some View {
        ZStack {
            // Background matching HomeView style
            Image("backgroundPhoto")
                .resizable()
                .scaledToFill()
                .overlay(Color.black.opacity(0.25))
                .ignoresSafeArea()
                .blur(radius: 13)
            
            TabView(selection: $currentPage) {
                // Slide 1: How to Play
                InstructionsSlide()
                    .tag(0)
                
                // Slide 2: Objects to Find
                ObjectsSlide(objects: selectedObjects, gameState: gameState)
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .overlay(alignment: .top) {
                PageIndicator(count: 2, currentIndex: currentPage)
                    .padding(.top, 12)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button("Cancel") {
//                    dismiss()
//                }
//                .foregroundStyle(.white)
//            }
//        }
    }
}

struct InstructionsSlide: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 80))
                    .foregroundStyle(.white)
                
                Text("How to Play")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 20) {
                InstructionRow(
                    icon: "1.circle.fill",
                    text: "Find 6 objects during your road trip"
                )
                InstructionRow(
                    icon: "2.circle.fill",
                    text: "Take photos of each object you spot"
                )
                InstructionRow(
                    icon: "3.circle.fill",
                    text: "Complete the challenge in 30 minutes"
                )
                InstructionRow(
                    icon: "4.circle.fill",
                    text: "Earn points for each object found"
                )
            }
            .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
    }
}

struct InstructionRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundStyle(.white)
            
            Text(text)
                .font(.system(size: 20))
                .foregroundStyle(.white)
        }
    }
}

@available(iOS 17.0, *)
struct ObjectsSlide: View {
    let objects: [GameObject]
    let gameState: GameState
    @State private var navigateToGame = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("Objects to Find")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(.white)
                .padding(.top, 40)
            
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(objects) { object in
                        ObjectCard(object: object)
                            .frame(width: min(UIScreen.main.bounds.width - 80, UIScreen.main.bounds.width))
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Button {
                gameState.startChallenge(objects: objects)
                navigateToGame = true
            } label: {
                Text("Start Game!")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.white)
                    .frame(width: min(UIScreen.main.bounds.width - 80, UIScreen.main.bounds.width))
                    
                    .frame(height: 55)
                    .background(Color.blue)
                    .clipShape(Capsule())
                    .shadow(radius: 5)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
            .navigationDestination(isPresented: $navigateToGame) {
                GameView(gameState: gameState)
            }
        }
    }
}

struct ObjectCard: View {
    let object: GameObject
    
    var difficultyColor: Color {
        switch object.difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(object.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.black)
                
                HStack {
                    Text(object.difficulty.rawValue.capitalized)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(difficultyColor)
                    
                    Text("•")
                        .foregroundStyle(.gray)
                    
                    Text("\(object.points) pts")
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                }
            }
            
            Spacer()
            
            Image(systemName: "circle")
                .font(.system(size: 24))
                .foregroundStyle(.gray)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(radius: 3)
    }
}

struct PageIndicator: View {
    let count: Int
    let currentIndex: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color.white : Color.white.opacity(0.4))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Color.black.opacity(0.25))
        .clipShape(Capsule())
    }
}

#Preview {
    NavigationStack {
        if #available(iOS 17.0, *) {
            OnboardingView(gameState: GameState())
        } else {
            // Fallback on earlier versions
        }
    }
}

