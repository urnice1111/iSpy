import SwiftUI

@available(iOS 17.0, *)
struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentPage = 0
    @State private var selectedObjects: [GameObject] = []
    @Binding var popToRoot: Bool
    var gameState: GameState
    var isGamePlaying: Bool = false
    
    init(gameState: GameState, popToRoot: Binding<Bool>) {
        self.gameState = gameState
        self._popToRoot = popToRoot
        _selectedObjects = State(initialValue: ObjectDatabase.getRandomObjects())
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $currentPage) {
                // Slide 1: How to Play
                InstructionsSlide()
                    .tag(0)
                
                AvoidView()
                    .tag(1)
                // Slide 2: Objects to Find
                ObjectsSlide(objects: selectedObjects, gameState: gameState, popToRoot: $popToRoot)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .overlay(alignment: .bottom) {
                PageIndicator(count: 2, currentIndex: currentPage)
                    .padding(.bottom, 20)
            }
        }
        .background(Color("BackgroundColor"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.light, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }
}

// MARK: - Instructions Slide
struct InstructionsSlide: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Header with icon
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.purple.opacity(0.2), .pink.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                Text("How to Play")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }
            
            // Instructions list
            VStack(alignment: .leading, spacing: 16) {
                InstructionRow(
                    number: 1,
                    text: "Find 6 objects during your road trip",
                    icon: "magnifyingglass"
                )
                InstructionRow(
                    number: 2,
                    text: "Take photos of each object you spot",
                    icon: "camera.fill"
                )
                InstructionRow(
                    number: 3,
                    text: "Complete the challenge in 30 minutes",
                    icon: "clock.fill"
                )
                InstructionRow(
                    number: 4,
                    text: "Earn points for each object found",
                    icon: "star.fill"
                )
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color("WidgetColor").opacity(0.5))
                    )
            )
            .shadow(color: .black.opacity(0.08), radius: 12, y: 6)
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Swipe hint
            HStack(spacing: 6) {
                Text("Swipe to continue")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 60)
        }
    }
}
// MARK: - Avoid View
struct AvoidView: View {
    var body: some View {
        VStack(spacing: 32){
            
            Spacer()
            
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 90))
                .foregroundStyle(
                    Color.yellow
                )
            
            Text("Safety first!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Text("Do not use this app while driving. Always stay alert and aware of your surroundings.")
                .font(.body)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Spacer()
            
            // Swipe hint
            HStack(spacing: 6) {
                Text("Swipe to continue")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 60)
        }
        
        
    }
}

// MARK: - Instruction Row
struct InstructionRow: View {
    let number: Int
    let text: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Number badge with gradient
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)
                
                Text("\(number)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
            
            Text(text)
                .font(.body)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.secondary)
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
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Your Mission")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text("Find these \(objects.count) objects")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 20)
            
            // Objects list
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(objects) { object in
                        ObjectCard(object: object)
                    }
                }
                .padding(.horizontal, 24)
            }
            
            // Start button with gradient
            Button {
                gameState.startChallenge(objects: objects)
                navigateToGame = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "flag.checkered")
                        .font(.headline)
                    Text("Start Adventure")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .purple.opacity(0.3), radius: 10, y: 5)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 80)
            .navigationDestination(isPresented: $navigateToGame) {
                GameView(gameState: gameState, popToRoot: $popToRoot)
            }
        }
    }
}

// MARK: - Object Card
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
        HStack(spacing: 16) {
            // Difficulty indicator circle
            Circle()
                .fill(difficultyColor.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: "scope")
                        .font(.body)
                        .foregroundStyle(difficultyColor)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(object.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                HStack(spacing: 8) {
                    // Difficulty badge
                    Text(object.difficulty.rawValue.capitalized)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(difficultyColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(difficultyColor.opacity(0.15))
                        .clipShape(Capsule())
                    
                    // Points
                    Label("\(object.points)", systemImage: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Checkbox style indicator
            Circle()
                .strokeBorder(Color.secondary.opacity(0.3), lineWidth: 2)
                .frame(width: 26, height: 26)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("WidgetColor").opacity(0.5))
                )
        )
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}

// MARK: - Page Indicator
struct PageIndicator: View {
    let count: Int
    let currentIndex: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == currentIndex ? Color.purple : Color.secondary.opacity(0.3))
                    .frame(width: index == currentIndex ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.3), value: currentIndex)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
        )
    }
}

#Preview {
    NavigationStack {
        if #available(iOS 17.0, *) {
            OnboardingView(gameState: GameState(), popToRoot: .constant(false))
        } else {
            // Fallback on earlier versions
        }
    }
}
