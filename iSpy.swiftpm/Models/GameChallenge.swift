import Foundation

struct GameChallenge: Identifiable, Codable {
    let id: UUID
    var objectsToFind: [GameObject]
    var foundObjects: [GameObject]
    let startTime: Date
    let durationMinutes: Int
    var isCompleted: Bool
    var isExpired: Bool
    
    init(id: UUID = UUID(), objectsToFind: [GameObject], durationMinutes: Int = 30) {
        self.id = id
        self.objectsToFind = objectsToFind
        self.foundObjects = []
        self.startTime = Date()
        self.durationMinutes = durationMinutes
        self.isCompleted = false
        self.isExpired = false
    }
    
    var remainingTime: TimeInterval {
        let elapsed = Date().timeIntervalSince(startTime)
        let total = TimeInterval(durationMinutes * 60)
        let remaining = total - elapsed
        return max(0, remaining)
    }
    
    var progress: Double {
        guard !objectsToFind.isEmpty else { return 0 }
        return Double(foundObjects.count) / Double(objectsToFind.count)
    }
    
    func isObjectFound(_ object: GameObject) -> Bool {
        foundObjects.contains { $0.id == object.id }
    }
    
    mutating func markObjectFound(_ object: GameObject) {
        if !isObjectFound(object) && objectsToFind.contains(where: { $0.id == object.id }) {
            foundObjects.append(object)
        }
        
        // Check if all objects are found
        if foundObjects.count == objectsToFind.count {
            isCompleted = true
        }
    }
    
    mutating func checkExpiration() {
        if remainingTime <= 0 && !isCompleted {
            isExpired = true
        }
    }
}

