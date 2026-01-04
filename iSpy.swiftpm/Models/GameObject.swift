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
        // EASY
        GameObject(name: "Car", category: "Vehicle", difficulty: .easy),
        GameObject(name: "Truck", category: "Vehicle", difficulty: .easy),
        GameObject(name: "Bus", category: "Vehicle", difficulty: .easy),
        GameObject(name: "Motorcycle", category: "Vehicle", difficulty: .easy),
        GameObject(name: "Bicycle", category: "Vehicle", difficulty: .easy),
        GameObject(name: "Traffic Light", category: "Road", difficulty: .easy), //listo
        GameObject(name: "Stop Sign / Traffic Sign", category: "Road", difficulty: .easy),
        
        // MEDIUM
        GameObject(name: "Bridge", category: "Infrastructure", difficulty: .medium),
        GameObject(name: "Tunnel", category: "Infrastructure", difficulty: .medium),
        GameObject(name: "Street Light", category: "Road", difficulty: .medium),
        GameObject(name: "Gas Station", category: "Urban", difficulty: .medium),
        GameObject(name: "Building", category: "Infrastructure", difficulty: .medium), //listo de bdd100k e imagnes del data set de mierda
        
        // HARD

        GameObject(name: "Monument / Statue", category: "Urban", difficulty: .hard),
        GameObject(name: "Wild Animal (Deer/Horse/Cow)", category: "Nature", difficulty: .hard),
    ]
    
    static func getRandomObjects(easy: Int = 3, medium: Int = 2, hard: Int = 1) -> [GameObject] {
        let easyObjects = allObjects.filter { $0.difficulty == .easy }.shuffled().prefix(easy)
        //        let mediumObjects = allObjects.filter { $0.difficulty == .medium }.shuffled().prefix(medium)
        //        let hardObjects = allObjects.filter { $0.difficulty == .hard }.shuffled().prefix(hard)
        
        return Array(easyObjects)  /*Array(mediumObjects) + Array(hardObjects)*/
    }
}

