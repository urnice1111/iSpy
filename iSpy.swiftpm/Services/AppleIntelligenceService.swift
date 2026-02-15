import Foundation
import FoundationModels

// MARK: - Quiz Question Model
struct QuizQuestion: Identifiable {
    let id = UUID()
    let question: String
    let correctAnswer: Bool  // true = verdadero, false = falso
}

private struct QuizQuestionDTO: Codable {
    let question: String
    let correctAnswer: Bool
}

// MARK: - Chat Message Model
struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp = Date()
}

// MARK: - Apple Intelligence Service
/// Service for generating AI descriptions and handling chat using Apple's on-device Foundation Models
@available(iOS 26.0, *)
@MainActor
@Observable
class AppleIntelligenceService {
    
    // MARK: - Properties
    private var session: LanguageModelSession?
    var chatMessages: [ChatMessage] = []
    var isGenerating: Bool = false
    var errorMessage: String?
    
    // Context for the current item
    private var currentObjectName: String = ""
    private var currentDescription: String = ""
    
    // MARK: - Availability Check
    
    /// Check if Apple Intelligence is available on this device
    static var isAvailable: Bool {
        SystemLanguageModel.default.isAvailable
    }
    
    // MARK: - Quiz Questions Generation
    
    /// Generate 3 true/false quiz questions about a found object
    /// - Parameter objectName: The name of the object
    /// - Returns: Array of 3 QuizQuestion with question text and correctAnswer (true/false)
    func generateQuizQuestions(for objectName: String) async throws -> [QuizQuestion] {
        guard Self.isAvailable else {
            throw AppleIntelligenceError.notAvailable
        }
        
        isGenerating = true
        errorMessage = nil
        
        defer { isGenerating = false }
        
        let prompt = """
        You are a friendly guide for a road trip discovery game called "iSpy".
        A player just found and photographed: "\(objectName)".
        
        Generate exactly 3 true or false questions about "\(objectName)". Make them fun, educational, and suitable for all ages. Each question should be a single statement (1 sentence max).
        
        Respond ONLY with a valid JSON array. No other text. Format:
        [{"question": "statement here", "correctAnswer": true}, {"question": "...", "correctAnswer": false}, {"question": "...", "correctAnswer": true}]
        
        Use "correctAnswer": true for TRUE statements, "correctAnswer": false for FALSE statements.
        """
        
        do {
            let session = LanguageModelSession()
            let response = try await session.respond(to: prompt)
            return try parseQuizQuestions(from: response.content)
        } catch {
            errorMessage = "Failed to generate quiz: \(error.localizedDescription)"
            throw error
        }
    }
    
    private func parseQuizQuestions(from content: String) throws -> [QuizQuestion] {
        // Extract JSON array from response (LLM may add extra text)
        guard let start = content.firstIndex(of: "["),
              let end = content.lastIndex(of: "]"),
              start < end else {
            throw AppleIntelligenceError.generationFailed("Invalid response format")
        }
        
        let jsonString = String(content[start...end])
        guard let data = jsonString.data(using: .utf8) else {
            throw AppleIntelligenceError.generationFailed("Invalid encoding")
        }
        
        let dtos = try JSONDecoder().decode([QuizQuestionDTO].self, from: data)
        
        guard dtos.count >= 3 else {
            throw AppleIntelligenceError.generationFailed("Expected at least 3 questions")
        }
        
        return dtos.prefix(3).map { dto in
            QuizQuestion(question: dto.question, correctAnswer: dto.correctAnswer)
        }
    }
    
    
    // MARK: - Errors
    enum AppleIntelligenceError: LocalizedError {
        case notAvailable
        case noActiveSession
        case generationFailed(String)
        
        var errorDescription: String? {
            switch self {
            case .notAvailable:
                return "Apple Intelligence is not available on this device. Requires iPhone 15 Pro or newer, or M-series iPad."
            case .noActiveSession:
                return "No active chat session. Please start a new conversation."
            case .generationFailed(let reason):
                return "Failed to generate content: \(reason)"
            }
        }
    }
    
    // MARK: - Fallback for older iOS versions
    /// Stub service for devices that don't support Apple Intelligence
    @available(iOS 26.0, *)
    @Observable
    final class AppleIntelligenceServiceUnavailable: @unchecked Sendable {
        @MainActor static let shared = AppleIntelligenceServiceUnavailable()
        
        var chatMessages: [ChatMessage] = []
        var isGenerating: Bool = false
        var errorMessage: String? = "Apple Intelligence requires iOS 26.0 or later"
        
        static var isAvailable: Bool { false }
        
        init() {}
        
        func generateQuizQuestions(for objectName: String) async throws -> [QuizQuestion] {
            throw AppleIntelligenceError.notAvailable
        }
        
        func startChatSession(objectName: String, description: String?) async {
            errorMessage = "Apple Intelligence is not available"
        }
        
        func sendMessage(_ message: String) async throws -> String {
            throw AppleIntelligenceError.notAvailable
        }
        
        func clearChat() {
            chatMessages = []
        }
    }
}
