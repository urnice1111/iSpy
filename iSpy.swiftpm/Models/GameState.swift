import Foundation
import SwiftUI

@available(iOS 17.0, *)
@Observable
class GameState {
    var currentChallenge: GameChallenge?
    var collectedItems: [CollectedItem] = []
    var totalScore: Int = 0
    var completedChallengesCount: Int = 0
    
    private let userDefaults = UserDefaults.standard
    private let challengeKey = "currentChallenge"
    private let collectedItemsKey = "collectedItems"
    private let totalScoreKey = "totalScore"
    private let completedChallengesKey = "completedChallengesCount"
    
    init() {
        loadState()
    }
    
    func startChallenge(objects: [GameObject], durationMinutes: Int = 30) {
        currentChallenge = GameChallenge(objectsToFind: objects, durationMinutes: durationMinutes)
        saveState()
    }
    
    func completeObject(_ object: GameObject, imageData: Data?) {
        guard var challenge = currentChallenge else { return }
        
        challenge.markObjectFound(object)
        currentChallenge = challenge
        
        // Save image to file system and get the path
        var imagePath: String? = nil
        if let data = imageData {
            imagePath = CollectedItem.saveImage(data)
        }
        
        // Add to collected items with just the path (not the data)
        let item = CollectedItem(object: object, imagePath: imagePath, challengeId: challenge.id)
        collectedItems.append(item)
        
        // Update score
        totalScore += object.points
        
        saveState()
    }
    
    func finishChallenge() {
        guard currentChallenge != nil else { return }
        
        completedChallengesCount += 1
        currentChallenge = nil
        
        saveState()
    }
    
    func cancelChallenge() {
        currentChallenge = nil
        saveState()
    }
    
    func saveState() {
        // Capture current values to avoid race conditions
        let challenge = currentChallenge
        let items = collectedItems
        let score = totalScore
        let completedCount = completedChallengesCount
        // Capture keys locally as Sendable values (String is Sendable)
        let challengeKey = self.challengeKey
        let collectedItemsKey = self.collectedItemsKey
        let totalScoreKey = self.totalScoreKey
        let completedChallengesKey = self.completedChallengesKey
        
        // Perform encoding and saving on background queue to avoid UI freezes
        DispatchQueue.global(qos: .utility).async {
            // Use UserDefaults.standard directly to avoid capturing non-Sendable self
            let defaults = UserDefaults.standard
            
            // Save current challenge
            if let challenge = challenge {
                if let encoded = try? JSONEncoder().encode(challenge) {
                    defaults.set(encoded, forKey: challengeKey)
                }
            } else {
                defaults.removeObject(forKey: challengeKey)
            }
            
            // Save collected items
            if let encoded = try? JSONEncoder().encode(items) {
                defaults.set(encoded, forKey: collectedItemsKey)
            }
            
            // Save score and stats
            defaults.set(score, forKey: totalScoreKey)
            defaults.set(completedCount, forKey: completedChallengesKey)
        }
    }
    
    func loadState() {
        // Load current challenge
        if let data = userDefaults.data(forKey: challengeKey),
           let challenge = try? JSONDecoder().decode(GameChallenge.self, from: data) {
            currentChallenge = challenge
        }
        
        // Load collected items
        if let data = userDefaults.data(forKey: collectedItemsKey),
           let items = try? JSONDecoder().decode([CollectedItem].self, from: data) {
            collectedItems = items
        }
        
        // Load score and stats
        totalScore = userDefaults.integer(forKey: totalScoreKey)
        completedChallengesCount = userDefaults.integer(forKey: completedChallengesKey)
    }
    
    func resetGame() {
        currentChallenge = nil
        collectedItems = []
        totalScore = 0
        completedChallengesCount = 0
        saveState()
    }
    
    /// Update the AI-generated description for a collected item
    /// - Parameters:
    ///   - itemId: The UUID of the item to update
    ///   - description: The AI-generated description to save
    func updateItemDescription(_ itemId: UUID, description: String) {
        if let index = collectedItems.firstIndex(where: { $0.id == itemId }) {
            collectedItems[index].aiDescription = description
            saveState()
        }
    }
}

