import Foundation
import SwiftUI
import UIKit

final class ImageCache: @unchecked Sendable {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }
    
    func image(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        let cost = Int(image.size.width * image.size.height * image.scale * 4)
        cache.setObject(image, forKey: key as NSString, cost: cost)
    }
    
}

struct CollectedItem: Identifiable, Codable {
    let id: UUID
    let object: GameObject
    let imagePath: String?
    let timestamp: Date
    let challengeId: UUID
    var aiDescription: String?
    var quizBonusPoints: Int?
    var drawingData: Data?
    var placedStickers: [PlacedSticker]
    
    init(id: UUID = UUID(), object: GameObject, imagePath: String? = nil, timestamp: Date = Date(), challengeId: UUID, aiDescription: String? = nil, quizBonusPoints: Int? = nil, drawingData: Data? = nil, placedStickers: [PlacedSticker] = []) {
        self.id = id
        self.object = object
        self.imagePath = imagePath
        self.timestamp = timestamp
        self.challengeId = challengeId
        self.aiDescription = aiDescription
        self.quizBonusPoints = quizBonusPoints
        self.drawingData = drawingData
        self.placedStickers = placedStickers
    }
    
    var image: Image? {
        guard let imagePath = imagePath else { return nil }
        
        // Check cache first
        if let cachedImage = ImageCache.shared.image(forKey: imagePath) {
            return Image(uiImage: cachedImage)
        }
        
        // Load from disk and cache
        let url = CollectedItem.imagesDirectory.appendingPathComponent(imagePath)
        guard let data = try? Data(contentsOf: url),
              let uiImage = UIImage(data: data) else {
            return nil
        }
        
        // Store in cache for future access
        ImageCache.shared.setImage(uiImage, forKey: imagePath)
        
        return Image(uiImage: uiImage)
    }
    
    // Directory for storing images
    static var imagesDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let imagesDir = paths[0].appendingPathComponent("CollectedImages")
        
        // Create directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: imagesDir.path) {
            try? FileManager.default.createDirectory(at: imagesDir, withIntermediateDirectories: true)
        }
        
        return imagesDir
    }
    
    // Save image to file system and return the filename
    static func saveImage(_ imageData: Data) -> String? {
        let filename = UUID().uuidString + ".jpg"
        let url = imagesDirectory.appendingPathComponent(filename)
        
        do {
            try imageData.write(to: url)
            return filename
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
}

