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
        // --- EASY (Colores vibrantes y formas únicas) ---
        GameObject(name: "Traffic Cone", category: "Road", difficulty: .easy), //listo down
//        GameObject(name: "Fire Hydrant", category: "Urban", difficulty: .easy), //listo down
//        GameObject(name: "Bicycle", category: "Vehicle", difficulty: .easy), //listo down
//        GameObject(name: "Bus Stop", category: "Urban", difficulty: .easy), //listo downloaded splitted
//        GameObject(name: "Zebra Crossing", category: "Road", difficulty: .easy), //listo down
        GameObject(name: "Traffic Light", category: "Road", difficulty: .easy), //listo down splitted
        GameObject(name: "Stop Sign", category: "Road", difficulty: .easy), //listo down

        // --- MEDIUM (Requieren más atención al entorno) ---
        GameObject(name: "Wind Turbine", category: "Energy", difficulty: .medium), //listo down
        GameObject(name: "Electric Tower", category: "Infrastructure", difficulty: .medium), //listo down
        GameObject(name: "Road Sign", category: "Road", difficulty: .medium), //listo down
        GameObject(name: "Construction Crane", category: "Construction", difficulty: .medium), //listo down
        GameObject(name: "Cow", category: "Nature", difficulty: .medium), //listo down
        GameObject(name: "Gas Station", category: "Urban", difficulty: .medium), //listo down
//        GameObject(name: "Bridge", category: "Infrastructure", difficulty: .medium),

        // --- HARD (Objetos en movimiento o menos frecuentes) ---
        GameObject(name: "Police Car", category: "Emergency", difficulty: .hard), //listo down
        GameObject(name: "Ambulance", category: "Emergency", difficulty: .hard), //listo
        GameObject(name: "Tractor", category: "Farm", difficulty: .hard), //listo
        GameObject(name: "Church", category: "Urban", difficulty: .hard) //listo
    ]
    
    static func getRandomObjects(easy: Int = 3, medium: Int = 2, hard: Int = 1) -> [GameObject] {
        let easyObjects = allObjects.filter { $0.difficulty == .easy }.shuffled().prefix(easy)
        //        let mediumObjects = allObjects.filter { $0.difficulty == .medium }.shuffled().prefix(medium)
        //        let hardObjects = allObjects.filter { $0.difficulty == .hard }.shuffled().prefix(hard)
        
        return Array(easyObjects)  /*Array(mediumObjects) + Array(hardObjects)*/
    }
}

