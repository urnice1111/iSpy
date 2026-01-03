import Foundation

enum Difficulty: String, Codable, CaseIterable {
    case easy
    case medium
    case hard
    
    var points: Int {
        switch self {
        case .easy: return 10
        case .medium: return 25
        case .hard: return 50
        }
    }
}

struct GameObject: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let category: String
    let difficulty: Difficulty
    var points: Int { difficulty.points }
    
    init(id: UUID = UUID(), name: String, category: String, difficulty: Difficulty) {
        self.id = id
        self.name = name
        self.category = category
        self.difficulty = difficulty
    }
}

// Static database of objects - ready for JSON migration later
struct ObjectDatabase {
    static let allObjects: [GameObject] = [
        // Easy objects
        GameObject(name: "Speed Sign", category: "Road", difficulty: .easy),
        GameObject(name: "Car", category: "Vehicle", difficulty: .easy),
        GameObject(name: "Traffic Sign", category: "Nature", difficulty: .easy),
//        GameObject(name: "Building", category: "Urban", difficulty: .easy),
//        GameObject(name: "Cloud", category: "Sky", difficulty: .easy),
//        GameObject(name: "Street Light", category: "Road", difficulty: .easy),
//        GameObject(name: "Road", category: "Road", difficulty: .easy),
//        GameObject(name: "Grass", category: "Nature", difficulty: .easy),
//        GameObject(name: "Bridge", category: "Infrastructure", difficulty: .easy),
        
        // Medium objects
        GameObject(name: "Mountain", category: "Nature", difficulty: .medium),
        GameObject(name: "Lake", category: "Water", difficulty: .medium),
        GameObject(name: "Tunnel", category: "Infrastructure", difficulty: .medium),
        GameObject(name: "Restaurant", category: "Urban", difficulty: .medium),
        GameObject(name: "Gas Station", category: "Road", difficulty: .medium),
        GameObject(name: "Truck", category: "Vehicle", difficulty: .medium),
        GameObject(name: "Boat", category: "Vehicle", difficulty: .medium),
        GameObject(name: "Windmill", category: "Infrastructure", difficulty: .medium),
        GameObject(name: "Farm", category: "Rural", difficulty: .medium),
        GameObject(name: "Monument", category: "Urban", difficulty: .medium),
        
        // Hard objects
        GameObject(name: "Wildlife", category: "Nature", difficulty: .hard),
        GameObject(name: "Historic Marker", category: "Urban", difficulty: .hard),
        GameObject(name: "Scenic Overlook", category: "Nature", difficulty: .hard),
        GameObject(name: "Vintage Car", category: "Vehicle", difficulty: .hard),
        GameObject(name: "Lighthouse", category: "Infrastructure", difficulty: .hard),
        GameObject(name: "Canyon", category: "Nature", difficulty: .hard),
        GameObject(name: "Waterfall", category: "Nature", difficulty: .hard),
        GameObject(name: "Desert", category: "Landscape", difficulty: .hard),
        GameObject(name: "Castle", category: "Urban", difficulty: .hard),
        GameObject(name: "Cave", category: "Nature", difficulty: .hard),
    ]
    
    static func getRandomObjects(easy: Int = 3, medium: Int = 2, hard: Int = 1) -> [GameObject] {
        let easyObjects = allObjects.filter { $0.difficulty == .easy }.shuffled().prefix(easy)
        let mediumObjects = allObjects.filter { $0.difficulty == .medium }.shuffled().prefix(medium)
        let hardObjects = allObjects.filter { $0.difficulty == .hard }.shuffled().prefix(hard)
        
        return Array(easyObjects)  /*Array(mediumObjects) + Array(hardObjects)*/
    }
}

