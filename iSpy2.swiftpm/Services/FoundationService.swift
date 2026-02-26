import Foundation
import FoundationModels

// MARK: - Quiz Question Model
struct QuizQuestion: Identifiable {
    let id = UUID()
    let question: String
    let correctAnswer: Bool  // true = verdadero, false = falso
}

// MARK: - Generable Quiz Structs
@available(iOS 26.0, *)
@Generable
struct GeneratedQuizQuestion {
    @Guide(description: "A single true-or-false statement about the object. One sentence max. Fun and educational.")
    var question: String
    
    @Guide(description: "true if the statement is correct, false if it is incorrect")
    var correctAnswer: Bool
}

@available(iOS 26.0, *)
@Generable
struct GeneratedQuiz {
    @Guide(description: "Exactly 3 true-or-false questions about the object, suitable for all ages")
    @Guide(.count(3...3))
    var questions: [GeneratedQuizQuestion]
}

@available(iOS 26.0, *)
@MainActor
@Observable
class AppleIntelligenceService {
    
    // MARK: - Properties
    var isGenerating: Bool = false
    var errorMessage: String?
    
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
        Generate 3 true or false questions about "\(objectName)".
        Make them fun, educational, and suitable for all ages.
        """
        
        do {
            let session = LanguageModelSession()
            let response = try await session.respond(
                to: prompt,
                generating: GeneratedQuiz.self
            )
            return response.content.questions.map { q in
                QuizQuestion(question: q.question, correctAnswer: q.correctAnswer)
            }
        } catch {
            errorMessage = "Failed to generate quiz: \(error.localizedDescription)"
            throw error
        }
    }
    
    
    // MARK: - Errors
    enum AppleIntelligenceError: LocalizedError {
        case notAvailable
        
        var errorDescription: String? {
            switch self {
            case .notAvailable:
                return "Apple Intelligence is not available on this device. Requires iPhone 15 Pro or newer, or M-series iPad."
            }
        }
    }
}

