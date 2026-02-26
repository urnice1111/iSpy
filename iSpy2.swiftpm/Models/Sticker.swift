import Foundation
import SwiftUI

struct StickerDefinition: Identifiable, Codable, Hashable {
    let id: String
    let imageName: String
    let price: Int
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
        StickerDefinition(id: "s_trafficcone", imageName: "trafficcone", price: 5),
        StickerDefinition(id: "s_firehydrant", imageName: "firehydrant", price: 5),
        StickerDefinition(id: "s_trafficlight", imageName: "trafficlight", price: 5),
        StickerDefinition(id: "s_stopsign", imageName: "stopsign", price: 5),
        StickerDefinition(id: "s_foundit", imageName: "foundit_sticker", price: 5),
        StickerDefinition(id: "s_wow", imageName: "wow_sticker", price: 5),
        StickerDefinition(id: "s_glasses", imageName: "glasses_sticker", price: 5),
        // Medium tier — 10 points
        StickerDefinition(id: "s_windturbine", imageName: "windturbine", price: 10),
        StickerDefinition(id: "s_sun", imageName: "sun_sticker", price: 10),
        StickerDefinition(id: "s_electrictower", imageName: "electrictower", price: 10),
        StickerDefinition(id: "s_rainbow", imageName: "rainbow_sticker", price: 10),
        // Hard tier — 15 points
        StickerDefinition(id: "s_certified", imageName: "certified_sticker", price: 15),
        // Bonus decorations using existing assets
        StickerDefinition(id: "s_star", imageName: "Star", price: 3),
        StickerDefinition(id: "s_flag", imageName: "flag", price: 3),
        StickerDefinition(id: "s_nube", imageName: "Nube", price: 3),
    ]
}
