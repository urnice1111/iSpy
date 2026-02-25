import Foundation
import SwiftUI

@available(iOS 17.0, *)
@Observable
class GameState {
    var currentChallenge: GameChallenge?
    var collectedItems: [CollectedItem] = []
    var totalScore: Int = 0
    var completedChallengesCount: Int = 0
    var challengeTitles: [String: String] = [:]
    
    private let userDefaults = UserDefaults.standard
    private let challengeKey = "currentChallenge"
    private let collectedItemsKey = "collectedItems"
    private let totalScoreKey = "totalScore"
    private let completedChallengesKey = "completedChallengesCount"
    private let challengeTitlesKey = "challengeTitles"
    
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
//        var imagePath: String? = nil
//        if let data = imageData {
//            imagePath = CollectedItem.saveImage(data)
//        }
        
        // Add to collected items with just the path (not the data)
        let item = CollectedItem(object: object, challengeId: challenge.id)
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
    
    func updateChallengeTitle(_ challengeId: UUID, title: String) {
        challengeTitles[challengeId.uuidString] = title
        saveState()
    }
    
    func saveState() {
        let challenge = currentChallenge
        let items = collectedItems
        let score = totalScore
        let completedCount = completedChallengesCount
        let titles = challengeTitles
        let challengeKey = self.challengeKey
        let collectedItemsKey = self.collectedItemsKey
        let totalScoreKey = self.totalScoreKey
        let completedChallengesKey = self.completedChallengesKey
        let challengeTitlesKey = self.challengeTitlesKey
        
        DispatchQueue.global(qos: .utility).async {
            let defaults = UserDefaults.standard
            
            if let challenge = challenge {
                if let encoded = try? JSONEncoder().encode(challenge) {
                    defaults.set(encoded, forKey: challengeKey)
                }
            } else {
                defaults.removeObject(forKey: challengeKey)
            }
            
            if let encoded = try? JSONEncoder().encode(items) {
                defaults.set(encoded, forKey: collectedItemsKey)
            }
            
            if let encoded = try? JSONEncoder().encode(titles) {
                defaults.set(encoded, forKey: challengeTitlesKey)
            }
            
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
        
        if let data = userDefaults.data(forKey: challengeTitlesKey),
           let titles = try? JSONDecoder().decode([String: String].self, from: data) {
            challengeTitles = titles
        }
        
        totalScore = userDefaults.integer(forKey: totalScoreKey)
        completedChallengesCount = userDefaults.integer(forKey: completedChallengesKey)
    }
    
    func resetGame() {
        currentChallenge = nil
        collectedItems = []
        totalScore = 0
        completedChallengesCount = 0
        challengeTitles = [:]
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
    
    /// Add quiz bonus points for a collected item (one-time per item)
    /// - Parameters:
    ///   - itemId: The UUID of the item
    ///   - bonusPoints: Points to add (5 per correct answer, max 15)
    func addQuizBonusPoints(itemId: UUID, bonusPoints: Int) {
        guard let index = collectedItems.firstIndex(where: { $0.id == itemId }) else { return }
        guard collectedItems[index].quizBonusPoints == nil else { return }
        
        collectedItems[index].quizBonusPoints = bonusPoints
        totalScore += bonusPoints
        saveState()
    }
    
    /// Reset quiz for a collected item (debug only) - subtracts previous bonus and clears quiz state
    func resetQuiz(itemId: UUID) {
        guard let index = collectedItems.firstIndex(where: { $0.id == itemId }) else { return }
        if let previousBonus = collectedItems[index].quizBonusPoints {
            totalScore = max(0, totalScore - previousBonus)
        }
        collectedItems[index].quizBonusPoints = nil
        saveState()
    }
}

