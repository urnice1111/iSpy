//
//  ObjectDetailView.swift
//  iSpy
//
//  Created by UwU on 22/02/26.
//
import SwiftUI
import FoundationModels

@available(iOS 26.0, *)
struct ObjectDetailView: View {
    
    var collectedItem: CollectedItem
    @Environment(GameState.self) var gameState
    @Environment(\.dismiss) private var dismiss
    
    @State private var aiService = AppleIntelligenceService()
    @State private var quizQuestions: [QuizQuestion]?
    @State private var isGeneratingQuiz = false
    @State private var currentQuestionIndex = 0
    @State private var correctCount = 0
    @State private var completedQuizBonus: Int?
    @State private var showConfetti = false
    @State private var isRetrying = false
    
    private var currentItem: CollectedItem {
        gameState.collectedItems.first { $0.id == collectedItem.id } ?? collectedItem
    }
    
    var body: some View {
        ZStack {
            Image("BackgroundOnboarding")
                .resizable()
                .ignoresSafeArea()
            
            HStack(alignment: .center, spacing: 0) {
                Image(collectedItem.object.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .padding()
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(collectedItem.object.name)
                                .font(.custom("FredokaOne-Regular", size: 50))
                                .foregroundStyle(Color("StatsText"))
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                            Text("Captured: \(collectedItem.timestamp.formatted(date: .abbreviated, time: .omitted))")
                                .font(.custom("FredokaOne-Regular", size: 20))
                                .foregroundStyle(Color("StatsText"))
                                .lineLimit(1)
                        }
                        Spacer()
                        HStack {
                            Image("Star")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50)
                            
                            Text("\(collectedItem.object.points)")
                                .font(.custom("FredokaOne-Regular", size: 50))
                                .foregroundStyle(.black)
                                .lineLimit(1)
                        }
                    }
                    
                    quizSection
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(50)
            }
            
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .sensoryFeedback(.selection, trigger: showConfetti)
    }
    
    // MARK: - Quiz Section
    
    private var quizSection: some View {
        VStack(alignment: .leading, spacing: 12) {
//            HStack {
//                Image(systemName: "brain.head.profile")
//                    .font(.title2)
//                    .foregroundStyle(.indigo)
//                Text("Extra Points")
//                    .font(.custom("FredokaOne-Regular", size: 24))
//                    .foregroundStyle(Color("StatsText"))
//                Spacer()
//                if currentItem.quizBonusPoints != nil || completedQuizBonus != nil {
//                    Image(systemName: "checkmark.circle.fill")
//                        .foregroundStyle(.green)
//                        .font(.title2)
//                }
//            }
            
//            Text("Complete this quiz to earn extra points. This quiz is AI generated.")
//                .font(.custom("FredokaOne-Regular", size: 14))
//                .foregroundStyle(Color("StatsText").opacity(0.7))
            
            
            HStack{
                Image("Star")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 130)
                
                Spacer()
                
                Text("Complete this quiz to earn extra points!")
                    .font(.custom("FredokaOne-Regular", size: 30))
                    .foregroundStyle(Color("StatsText"))
            }
            
            if !isRetrying, let bonus = currentItem.quizBonusPoints ?? completedQuizBonus {
                quizCompletedView(bonus: bonus)
            } else if !AppleIntelligenceService.isAvailable {
                unavailableView
            } else if isGeneratingQuiz {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Generating questions...")
                        .font(.custom("FredokaOne-Regular", size: 16))
                        .foregroundStyle(Color("StatsText").opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(30)
            } else if let questions = quizQuestions, currentQuestionIndex < questions.count {
                VStack(spacing: 12) {
                    Text("Question \(currentQuestionIndex + 1) of 3")
                        .font(.custom("FredokaOne-Regular", size: 14))
                        .foregroundStyle(Color("StatsText").opacity(0.6))
                    
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
                                gameState.addQuizBonusPoints(itemId: collectedItem.id, bonusPoints: bonus)
                                withAnimation {
                                    showConfetti = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    withAnimation { showConfetti = false }
                                }
                            }
                        }
                    )
                    .id(questions[currentQuestionIndex].id)
                }
            } else if quizQuestions != nil, currentQuestionIndex >= 3 {
                quizJustCompletedView
            } else {
                Button {
                    Task { await startQuiz() }
                } label: {
                    HStack {
                        Image(systemName: "apple.intelligence")
                        Text("Start Quiz")
                            .font(.custom("FredokaOne-Regular", size: 18))
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
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Quiz Completed View
    
    private func quizCompletedView(bonus: Int) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(.yellow)
            Text("Quiz Completed!")
                .font(.custom("FredokaOne-Regular", size: 22))
                .foregroundStyle(Color("StatsText"))
            Text("You won \(bonus) extra points!")
                .font(.custom("FredokaOne-Regular", size: 16))
                .foregroundStyle(Color("StatsText").opacity(0.7))
            
            if bonus >= 15 {
                Text("You crushed it! Keep up the good work!")
                    .font(.custom("FredokaOne-Regular", size: 14))
                    .foregroundStyle(Color("StatsText").opacity(0.6))
            }
            
            Button {
                Task { await restartQuiz() }
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Retry Quiz")
                        .font(.custom("FredokaOne-Regular", size: 16))
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)
            .tint(.indigo)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Quiz Just Completed View
    
    private var quizJustCompletedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "party.popper.fill")
                .font(.system(size: 44))
                .foregroundStyle(.indigo)
            Text("You got \(correctCount) out of 3!")
                .font(.custom("FredokaOne-Regular", size: 22))
                .foregroundStyle(Color("StatsText"))
            Text("+\(completedQuizBonus ?? 0) bonus points")
                .font(.custom("FredokaOne-Regular", size: 20))
                .foregroundStyle(.green)
            
            Button {
                Task { await restartQuiz() }
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Retry Quiz")
                        .font(.custom("FredokaOne-Regular", size: 16))
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)
            .tint(.indigo)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Unavailable View
    
    private var unavailableView: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            
            Text("Apple Intelligence Unavailable")
                .font(.custom("FredokaOne-Regular", size: 18))
                .foregroundStyle(Color("StatsText"))
            
            Text("Requires iPhone 15 Pro or newer, or M-series iPad with iOS 26+")
                .font(.custom("FredokaOne-Regular", size: 14))
                .foregroundStyle(Color("StatsText").opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.orange.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Actions
    
    private func startQuiz() async {
        isGeneratingQuiz = true
        aiService.errorMessage = nil
        
        do {
            let questions = try await aiService.generateQuizQuestions(for: collectedItem.object.name)
            quizQuestions = questions
            currentQuestionIndex = 0
            correctCount = 0
        } catch {
            print("Failed to generate quiz: \(error)")
        }
        
        isGeneratingQuiz = false
    }
    
    private func restartQuiz() async {
        gameState.resetQuiz(itemId: collectedItem.id)
        quizQuestions = nil
        currentQuestionIndex = 0
        correctCount = 0
        completedQuizBonus = nil
        showConfetti = false
        isRetrying = true
        await startQuiz()
    }
}

// MARK: - Quiz Card View (swipe right = true, left = false)

@available(iOS 17.0, *)
struct QuizCardView: View {
    let question: QuizQuestion
    let onSwiped: (Bool) -> Void
    
    @State private var dragOffset: CGFloat = 0
    private let swipeThreshold: CGFloat = 100
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text(question.question)
                    .font(.custom("FredokaOne-Regular", size: 30))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, 24)
                
                HStack {
                    Label("False", systemImage: "xmark.circle.fill")
                        .font(.custom("FredokaOne-Regular", size: 14))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Label("True", systemImage: "checkmark.circle.fill")
                        .font(.custom("FredokaOne-Regular", size: 14))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 24)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 150)
            .padding(.vertical, 24)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
            )
            .overlay {
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

@available(iOS 26.0, *)
#Preview {
    let state: GameState = {
        let s = GameState()
        s.collectedItems = [
            CollectedItem(
                object: GameObject(name: "Traffic Cone", category: "Road", difficulty: .easy),
                challengeId: UUID()
            )
        ]
        return s
    }()
    
    NavigationStack {
        ObjectDetailView(
            collectedItem: state.collectedItems[0]
        )
    }
    .environment(state)
    .previewInterfaceOrientation(.landscapeLeft)
}
