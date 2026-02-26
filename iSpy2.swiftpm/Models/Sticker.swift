import Foundation
import SwiftUI

struct StickerDefinition: Identifiable, Codable, Hashable {
    let id: String
    let imageName: String
    let displayName: String
    let price: Int
    let category: String
}

struct PlacedSticker: Identifiable, Codable {
    let id: UUID
    let stickerImageName: String
    var positionX: CGFloat
    var positionY: CGFloat
    var scale: CGFloat
    var rotationDegrees: Double
    
    init(id: UUID = UUID(), stickerImageName: String, position: CGPoint, scale: CGFloat = 1.0, rotationDegrees: Double = 0) {
        self.id = id
        self.stickerImageName = stickerImageName
        self.positionX = position.x
        self.positionY = position.y
        self.scale = scale
        self.rotationDegrees = rotationDegrees
    }
    
    var position: CGPoint {
        get { CGPoint(x: positionX, y: positionY) }
        set { positionX = newValue.x; positionY = newValue.y }
    }
}

struct StickerCatalog {
    static let all: [StickerDefinition] = [
        // Easy tier — 5 points
        StickerDefinition(id: "s_trafficcone", imageName: "trafficcone", displayName: "Traffic Cone", price: 5, category: "Road"),
        StickerDefinition(id: "s_firehydrant", imageName: "firehydrant", displayName: "Fire Hydrant", price: 5, category: "Urban"),
        StickerDefinition(id: "s_trafficlight", imageName: "trafficlight", displayName: "Traffic Light", price: 5, category: "Road"),
        StickerDefinition(id: "s_stopsign", imageName: "stopsign", displayName: "Stop Sign", price: 5, category: "Road"),
        StickerDefinition(id: "s_foundit", imageName: "foundit_sticker", displayName: "Found It", price: 5, category: "Road"),
        StickerDefinition(id: "s_wow", imageName: "wow_sticker", displayName: "WOW", price: 5, category: "Road"),
        StickerDefinition(id: "s_glasses", imageName: "glasses_sticker", displayName: "Sun Glasses", price: 5, category: "Road"),
        // Medium tier — 10 points
        StickerDefinition(id: "s_windturbine", imageName: "windturbine", displayName: "Wind Turbine", price: 10, category: "Energy"),
        StickerDefinition(id: "s_sun", imageName: "sun_sticker", displayName: "Sun", price: 10, category: "Energy"),
        StickerDefinition(id: "s_electrictower", imageName: "electrictower", displayName: "Electric Tower", price: 10, category: "Infrastructure"),
        StickerDefinition(id: "s_rainbow", imageName: "rainbow_sticker", displayName: "Rainbow", price: 10, category: "Energy"),
        // Hard tier — 15 points
        StickerDefinition(id: "s_certified", imageName: "certified_sticker", displayName: "Certified Explorer", price: 15, category: "Emergency"),
        // Bonus decorations using existing assets
        StickerDefinition(id: "s_star", imageName: "Star", displayName: "Star", price: 3, category: "Decoration"),
        StickerDefinition(id: "s_flag", imageName: "flag", displayName: "Flag", price: 3, category: "Decoration"),
        StickerDefinition(id: "s_nube", imageName: "Nube", displayName: "Cloud", price: 3, category: "Decoration"),
    ]
}
