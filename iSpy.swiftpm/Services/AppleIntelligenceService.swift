import Foundation
import FoundationModels

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
    
    // MARK: - Description Generation
    
    /// Generate an AI description for a found object
    /// - Parameter objectName: The name of the object to describe
    /// - Returns: A fun, educational description of the object
    func generateDescription(for objectName: String) async throws -> String {
        guard Self.isAvailable else {
            throw AppleIntelligenceError.notAvailable
        }
        
        isGenerating = true
        errorMessage = nil
        
        defer { isGenerating = false }
        
        let prompt = """
        You are a friendly guide for a road trip discovery game called "iSpy". 
        A player just found and photographed: "\(objectName)"
        
        Write a fun, educational 2-3 sentence description about this object that would be interesting for someone on a road trip. 
        Include a cool fact if possible. Keep it suitable for all ages and engaging!
        """
        
        do {
            let session = LanguageModelSession()
            let response = try await session.respond(to: prompt)
            return response.content
        } catch {
            errorMessage = "Failed to generate description: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Chat Session
    
    /// Start a new chat session with context about the object
    /// - Parameters:
    ///   - objectName: The name of the object
    ///   - description: The AI-generated description (if any)
    func startChatSession(objectName: String, description: String?) async {
        guard Self.isAvailable else {
            errorMessage = "Apple Intelligence is not available on this device"
            return
        }
        
        currentObjectName = objectName
        currentDescription = description ?? "No description generated yet"
        chatMessages = []
        
        // Create a new session with system context
        let instructions = """
        You are a helpful assistant in a road trip discovery game called "iSpy".
        The user is asking about an object they found: "\(objectName)"
        
        Here's what we know about it: \(currentDescription)
        
        Be friendly, informative, and keep responses concise (2-4 sentences).
        If asked about things unrelated to the object, road trips, or exploration, 
        politely redirect the conversation back to the discovery.
        """
        
        do {
            session = LanguageModelSession(instructions: instructions)
        } catch {
            errorMessage = "Failed to start chat session"
        }
    }
    
    /// Send a message and get a response
    /// - Parameter message: The user's message
    /// - Returns: The AI's response
    @discardableResult
    func sendMessage(_ message: String) async throws -> String {
        guard let session = session else {
            throw AppleIntelligenceError.noActiveSession
        }
        
        guard Self.isAvailable else {
            throw AppleIntelligenceError.notAvailable
        }
        
        isGenerating = true
        errorMessage = nil
        
        // Add user message to chat
        let userMessage = ChatMessage(content: message, isUser: true)
        chatMessages.append(userMessage)
        
        defer { isGenerating = false }
        
        do {
            let response = try await session.respond(to: message)
            
            // Add AI response to chat
            let aiMessage = ChatMessage(content: response.content, isUser: false)
            chatMessages.append(aiMessage)
            
            return response.content
        } catch {
            errorMessage = "Failed to get response: \(error.localizedDescription)"
            throw error
        }
    }
    
    /// Clear the current chat session
    func clearChat() {
        chatMessages = []
        session = nil
        currentObjectName = ""
        currentDescription = ""
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
@available(iOS 17.0, *)
@Observable
final class AppleIntelligenceServiceUnavailable: @unchecked Sendable {
    @MainActor static let shared = AppleIntelligenceServiceUnavailable()
    
    var chatMessages: [ChatMessage] = []
    var isGenerating: Bool = false
    var errorMessage: String? = "Apple Intelligence requires iOS 26.0 or later"
    
    static var isAvailable: Bool { false }
    
    init() {}
    
    func generateDescription(for objectName: String) async throws -> String {
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

