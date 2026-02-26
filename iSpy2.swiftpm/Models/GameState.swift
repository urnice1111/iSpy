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
    var isCameraActive: Bool = false
    var isFullScreenActive: Bool = false
    var purchasedStickerIds: Set<String> = []
    
    private let userDefaults = UserDefaults.standard
    private let challengeKey = "currentChallenge"
    private let collectedItemsKey = "collectedItems"
    private let totalScoreKey = "totalScore"
    private let completedChallengesKey = "completedChallengesCount"
    private let challengeTitlesKey = "challengeTitles"
    private let purchasedStickersKey = "purchasedStickerIds"
    
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
        
//         Save image to file system and get the path
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
        let purchasedIds = purchasedStickerIds
        let purchasedStickersKey = self.purchasedStickersKey
        
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
            
            if let encoded = try? JSONEncoder().encode(purchasedIds) {
                defaults.set(encoded, forKey: purchasedStickersKey)
            }
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
        
        if let data = userDefaults.data(forKey: purchasedStickersKey),
           let ids = try? JSONDecoder().decode(Set<String>.self, from: data) {
            purchasedStickerIds = ids
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
    
    // MARK: - Stickers
    
    func purchaseSticker(_ sticker: StickerDefinition) -> Bool {
        guard totalScore >= sticker.price else { return false }
        guard !purchasedStickerIds.contains(sticker.id) else { return true }
        
        totalScore -= sticker.price
        purchasedStickerIds.insert(sticker.id)
        saveState()
        return true
    }
    
    func isStickerPurchased(_ stickerId: String) -> Bool {
        purchasedStickerIds.contains(stickerId)
    }
    
    func savePlacedStickers(itemId: UUID, stickers: [PlacedSticker]) {
        guard let index = collectedItems.firstIndex(where: { $0.id == itemId }) else { return }
        collectedItems[index].placedStickers = stickers
        saveState()
    }
    
    func saveDrawing(itemId: UUID, data: Data?) {
        guard let index = collectedItems.firstIndex(where: { $0.id == itemId }) else { return }
        collectedItems[index].drawingData = data
        saveState()
    }
}

