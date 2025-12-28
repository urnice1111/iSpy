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
        // Save current challenge
        if let challenge = currentChallenge {
            if let encoded = try? JSONEncoder().encode(challenge) {
                userDefaults.set(encoded, forKey: challengeKey)
            }
        } else {
            userDefaults.removeObject(forKey: challengeKey)
        }
        
        // Save collected items
        if let encoded = try? JSONEncoder().encode(collectedItems) {
            userDefaults.set(encoded, forKey: collectedItemsKey)
        }
        
        // Save score and stats
        userDefaults.set(totalScore, forKey: totalScoreKey)
        userDefaults.set(completedChallengesCount, forKey: completedChallengesKey)
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
}

