import SwiftUI
import FoundationModels

// MARK: - Item Detail View
/// Full screen view that shows item details and quiz section
@available(iOS 26.0, *)
struct ItemDetailView: View {
    let item: CollectedItem
    var gameState: GameState
    @Environment(\.dismiss) private var dismiss
    
    @State private var aiService = AppleIntelligenceService()
    @State private var quizQuestions: [QuizQuestion]?
    @State private var isGeneratingQuiz = false
    @State private var currentQuestionIndex = 0
    @State private var correctCount = 0
    @State private var completedQuizBonus: Int?
    @State private var showConfetti: Bool = false
    @State private var isRetrying = false
    
    private var currentItem: CollectedItem {
        gameState.collectedItems.first { $0.id == item.id } ?? item
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Hero Image
                heroImageSection
                
                // Object Info Card
                objectInfoCard
                
                // Quiz Section
                quizSection
            }
            .padding()
        }
        .sensoryFeedback(.selection, trigger: showConfetti)
        .background(Color(.systemGroupedBackground))
        .navigationTitle(item.object.name)
        .navigationBarTitleDisplayMode(.large)
        .overlay {
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
    }
    
    // MARK: - Hero Image Section
    
    private var heroImageSection: some View {
        Group {
            if let image = item.image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 250)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.system(size: 50))
                            .foregroundStyle(.gray)
                    }
            }
        }
    }
    
    // MARK: - Object Info Card
    
    private var objectInfoCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Discovery Details")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    HStack(spacing: 12) {
                        Label("\(item.object.points) points", systemImage: "star.fill")
                            .font(.subheadline)
                            .foregroundStyle(.orange)
                        
                        Label(item.object.category, systemImage: "tag.fill")
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                        
                        difficultyBadge
                    }
                    
                    Label(item.timestamp.formatted(date: .long, time: .shortened), systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Difficulty Badge
    
    private var difficultyBadge: some View {
        Text(item.object.difficulty.rawValue.capitalized)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(difficultyColor)
            .clipShape(Capsule())
    }
    
    // MARK: - Quiz Section
    
    private var quizSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundStyle(.indigo)
                Text("Extra points")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                Spacer()
                if currentItem.quizBonusPoints != nil || completedQuizBonus != nil {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
            
            if !isRetrying, let bonus = currentItem.quizBonusPoints ?? completedQuizBonus {
                // Already completed
                VStack(spacing: 12) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.yellow)
                    Text("Quiz completed")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("You won \(bonus) extra points!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    if (bonus >= 15){
                        Text("You crushed it! Keep up the good work!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Button {
                        Task { await restartQuiz() }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Retry Quiz")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.regular)
                    .tint(.indigo)
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.tertiarySystemGroupedBackground))
                )
            } else if !AppleIntelligenceService.isAvailable {
                unavailableView
            } else if isGeneratingQuiz {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Generating questions...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(40)
            } else if let questions = quizQuestions, currentQuestionIndex < questions.count {
                // Quiz in progress
                VStack(spacing: 16) {
                    Text("Question \(currentQuestionIndex + 1) of 3")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    
                    QuizCardView(
                        question: questions[currentQuestionIndex],
                        onSwiped: { userSaidTrue in
                            let correct = questions[currentQuestionIndex].correctAnswer == userSaidTrue
                            if correct { correctCount += 1 }
                            withAnimation {
                                currentQuestionIndex += 1
                            }
                            if currentQuestionIndex >= 3 {
                                let bonus = correctCount * 5
                                completedQuizBonus = bonus
                                isRetrying = false
                                gameState.addQuizBonusPoints(itemId: item.id, bonusPoints: bonus)
                                withAnimation {
                                    showConfetti = true
                                }
                                // Auto-dismiss confetti after 3 seconds
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    withAnimation { showConfetti = false }
                                }
                            }
                        }
                    )
                    .id(questions[currentQuestionIndex].id)
                }
            } else if quizQuestions != nil, currentQuestionIndex >= 3 {
                // Just completed - show result
                VStack(spacing: 16) {
                    Image(systemName: "party.popper.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.indigo)
                    Text("Acertaste \(correctCount) de 3")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("+\(completedQuizBonus ?? 0) puntos bonus")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                    
                    Button {
                        Task { await restartQuiz() }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Retry Quiz")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.regular)
                    .tint(.indigo)
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.tertiarySystemGroupedBackground))
                )
            } else {
                Button {
                    Task {
                        await startQuiz()
                    }
                } label: {
                    HStack {
                        Image(systemName: "apple.intelligence")
                        Text("Start Quiz")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.indigo)
                .disabled(isGeneratingQuiz)
            }
            
            if let error = aiService.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Unavailable View
    
    private var unavailableView: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            
            Text("Apple Intelligence Unavailable")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text("Requires iPhone 15 Pro or newer, or M-series iPad with iOS 26+")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Helper Properties
    
    private var difficultyColor: Color {
        switch item.object.difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
    
    // MARK: - Actions
    
    private func startQuiz() async {
        isGeneratingQuiz = true
        aiService.errorMessage = nil
        
        do {
            let questions = try await aiService.generateQuizQuestions(for: item.object.name)
            quizQuestions = questions
            currentQuestionIndex = 0
            correctCount = 0
        } catch {
            print("Failed to generate quiz: \(error)")
        }
        
        isGeneratingQuiz = false
    }
    
    private func restartQuiz() async {
        gameState.resetQuiz(itemId: item.id)
        quizQuestions = nil
        currentQuestionIndex = 0
        correctCount = 0
        completedQuizBonus = nil
        showConfetti = false
        isRetrying = true
        await startQuiz()
    }
}

// MARK: - Quiz Card View (Tinder-style swipe: right = true, left = false)

@available(iOS 17.0, *)
struct QuizCardView: View {
    let question: QuizQuestion
    let onSwiped: (Bool) -> Void
    
    @State private var dragOffset: CGFloat = 0
    private let swipeThreshold: CGFloat = 100
    
    var body: some View {
        ZStack {
            // Card content
            VStack(spacing: 20) {
                Text(question.question)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                HStack {
                    Label("False", systemImage: "xmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Label("True", systemImage: "checkmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 24)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 180)
            .padding(.vertical, 32)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
            )
            .overlay {
                // Swipe overlays on top - green (true) when dragging right
                if dragOffset > 0 {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.green.opacity(min(0.6, Double(dragOffset) / 150)))
                        .overlay(
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.white.opacity(min(1, Double(dragOffset) / 80)))
                        )
                        .allowsHitTesting(false)
                }
                // Red (false) when dragging left
                if dragOffset < 0 {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.red.opacity(min(0.6, Double(-dragOffset) / 150)))
                        .overlay(
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.white.opacity(min(1, Double(-dragOffset) / 80)))
                        )
                        .allowsHitTesting(false)
                }
            }
        }
        .offset(x: dragOffset)
        .rotationEffect(.degrees(Double(dragOffset) / 20), anchor: .bottom)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation.width
                }
                .onEnded { value in
                    let width = value.translation.width
                    if width > swipeThreshold {
                        withAnimation(.easeOut(duration: 0.2)) {
                            dragOffset = 500
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            onSwiped(true)
                        }
                    } else if width < -swipeThreshold {
                        withAnimation(.easeOut(duration: 0.2)) {
                            dragOffset = -500
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            onSwiped(false)
                        }
                    } else {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            dragOffset = 0
                        }
                    }
                }
        )
    }
}


// MARK: - Fallback View for older iOS

struct ItemDetailViewFallback: View {
    let item: CollectedItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Hero Image
                if let image = item.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 250)
                        .overlay {
                            Image(systemName: "photo")
                                .font(.system(size: 50))
                                .foregroundStyle(.gray)
                        }
                }
                
                // Info
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(item.object.difficulty.rawValue.capitalized)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(difficultyColor)
                            .clipShape(Capsule())
                        
                        Text("\(item.object.points) pts")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text("Found: \(item.timestamp.formatted(date: .long, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // AI Unavailable
                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.largeTitle)
                        .foregroundStyle(.indigo)
                    
                    Text("Apple Intelligence")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("AI features require iOS 26+ and a compatible device (iPhone 15 Pro or newer, M-series iPad)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.indigo.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(item.object.name)
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var difficultyColor: Color {
        switch item.object.difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
}

// MARK: - Confetti

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var color: Color
    var size: CGFloat
    var opacity: Double
    var rotation: Double
    var scale: CGFloat
}

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var isAnimating = false
    
    let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange, .mint, .cyan]
    let particleCount = 50
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size * 1.5)
                        .rotationEffect(.degrees(particle.rotation))
                        .scaleEffect(particle.scale)
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                startConfetti(in: geometry.size)
            }
        }
        .ignoresSafeArea()
    }
    
    private func startConfetti(in size: CGSize) {
        for _ in 0..<particleCount {
            let particle = ConfettiParticle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: -50...0)
                ),
                color: colors.randomElement() ?? .blue,
                size: CGFloat.random(in: 6...12),
                opacity: 1.0,
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.8...1.2)
            )
            particles.append(particle)
        }
        
        withAnimation(.easeIn(duration: 0.1)) {
            isAnimating = true
        }
        
        for i in particles.indices {
            let delay = Double.random(in: 0...0.5)
            let duration = Double.random(in: 1.5...3.0)
            let horizontalDrift = CGFloat.random(in: -100...100)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeIn(duration: duration)) {
                    particles[i].position.y = size.height + 50
                    particles[i].position.x += horizontalDrift
                    particles[i].rotation += Double.random(in: 180...720)
                    particles[i].opacity = 0
                }
            }
        }
    }
}


// MARK: - Preview

#Preview {
    NavigationStack {
        if #available(iOS 26.0, *) {
            ItemDetailView(
                item: CollectedItem(
                    object: GameObject(name: "Speed Sign", category: "Road", difficulty: .easy),
                    imagePath: nil,
                    challengeId: UUID()
                ),
                gameState: GameState()
            )
        }
    }
}

