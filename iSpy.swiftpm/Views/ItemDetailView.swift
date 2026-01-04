import SwiftUI
import FoundationModels

// MARK: - Item Detail View
/// Full screen view that shows item details, AI description, and chat interface
@available(iOS 26.0, *)
struct ItemDetailView: View {
    let item: CollectedItem
    var gameState: GameState
    @Environment(\.dismiss) private var dismiss
    
    @State private var isAIInfoExpanded: Bool = false
    @State private var aiService = AppleIntelligenceService()
    @State private var isGeneratingDescription = false
    @State private var chatInput = ""
    @State private var localDescription: String?
    @FocusState private var isChatFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Hero Image
                heroImageSection
                
                // Object Info Card
                objectInfoCard
                
                // AI Description Section
                descriptionSection
                
                // Chat Section
                if AppleIntelligenceService.isAvailable {
                    chatSection
                }
            }
            .padding()
        }
        .background(Color("BackgroundColor"))
        .navigationTitle(item.object.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.light, for: .navigationBar)
        .onAppear {
            localDescription = item.aiDescription
            Task {
                await aiService.startChatSession(
                    objectName: item.object.name,
                    description: localDescription
                )
            }
        }
        .onDisappear {
            aiService.clearChat()
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
                        .foregroundStyle(.black)
                    
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
        .background(Color("WidgetColor"))
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
    
    // MARK: - Description Section
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "apple.intelligence")
                    .font(.title2)
                    .foregroundStyle(.purple)
                Text("AI Description")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                
                Button {
                    isAIInfoExpanded.toggle()
                    
                } label: {
                    Image(systemName: "questionmark.circle")
                        .foregroundStyle(Color(.label).opacity(0.5))
                }
                
                Spacer()
                
                if localDescription != nil || item.aiDescription != nil {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
            
            if isAIInfoExpanded {
                Text("This description is generated by Apple Intelligence. It may not be 100% accurate.")
                    .font(.body)
                    .foregroundStyle(.black.opacity(0.8))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.red.opacity(0.1))
                    )
            }
            
            if let description = localDescription ?? item.aiDescription {
                //Show cache info if exists
                Text(description)
                    .font(.body)
                    .foregroundStyle(.black.opacity(0.8))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.purple.opacity(0.1))
                    )
            } else if !AppleIntelligenceService.isAvailable {
                // Apple Intelligence not available
                unavailableView
            } else {
                // Show generate button
                Button {
                    Task {
                        await generateDescription()
                    }
                } label: {
                    HStack {
                        if isGeneratingDescription {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "apple.intelligence")
                        }
                        Text(isGeneratingDescription ? "Generating..." : "Generate Description")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isGeneratingDescription)
            }
            
            if let error = aiService.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .background(Color("WidgetColor"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Chat Section
    
    private var chatSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                Text("Ask Questions")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
            }
            
            // Chat messages
            if !aiService.chatMessages.isEmpty {
                VStack(spacing: 12) {
                    ForEach(aiService.chatMessages) { message in
                        ChatBubble(message: message)
                    }
                }
                .padding(.vertical, 8)
            } else {
                HStack {
                    Image(systemName: "questionmark.bubble.fill")
                        .foregroundStyle(.blue)
                    Text("Ask me anything about \(item.object.name)!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Chat input
            HStack(spacing: 12) {
                TextField("Type a question...", text: $chatInput)
                    .textFieldStyle(.plain)
                    .padding(14)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .focused($isChatFocused)
                
                Button {
                    Task {
                        await sendMessage()
                    }
                } label: {
                    Image(systemName: aiService.isGenerating ? "hourglass" : "arrow.up.circle.fill")
                        .font(.title)
                        .foregroundStyle(chatInput.isEmpty ? Color.secondary : Color.blue)
                }
                .disabled(chatInput.isEmpty || aiService.isGenerating)
            }
        }
        .padding()
        .background(Color("WidgetColor"))
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
                .foregroundStyle(.black)
            
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
    
    private func generateDescription() async {
        isGeneratingDescription = true
        
        do {
            let description = try await aiService.generateDescription(for: item.object.name)
            localDescription = description
            
            // Save to game state
            gameState.updateItemDescription(item.id, description: description)
            
            // Update chat context with new description
            await aiService.startChatSession(
                objectName: item.object.name,
                description: description
            )
        } catch {
            print("Failed to generate description: \(error)")
        }
        
        isGeneratingDescription = false
    }
    
    private func sendMessage() async {
        let message = chatInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return }
        
        chatInput = ""
        isChatFocused = false
        
        do {
            try await aiService.sendMessage(message)
        } catch {
            print("Failed to send message: \(error)")
        }
    }
}

// MARK: - Chat Bubble

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer(minLength: 60) }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.body)
                    .padding(12)
                    .background(message.isUser ? Color.blue : Color(.systemGray5))
                    .foregroundStyle(message.isUser ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            
            if !message.isUser { Spacer(minLength: 60) }
        }
    }
}

// MARK: - Fallback View for older iOS

@available(iOS 17.0, *)
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
                .background(Color("WidgetColor"))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // AI Unavailable
                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.largeTitle)
                        .foregroundStyle(.purple)
                    
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
                .background(Color.purple.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding()
        }
        .background(Color("BackgroundColor"))
        .navigationTitle(item.object.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.light, for: .navigationBar)
    }
    
    private var difficultyColor: Color {
        switch item.object.difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
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

