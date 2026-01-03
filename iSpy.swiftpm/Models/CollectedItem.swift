import Foundation
import SwiftUI
import UIKit

// MARK: - Image Cache
/// Singleton cache for collected item images to avoid repeated disk reads
/// NSCache is thread-safe, so we can mark this as @unchecked Sendable
final class ImageCache: @unchecked Sendable {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        // Limit cache to ~50MB or 20 images
        cache.totalCostLimit = 50 * 1024 * 1024
        cache.countLimit = 20
    }
    
    func image(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        let cost = image.jpegData(compressionQuality: 1.0)?.count ?? 0
        cache.setObject(image, forKey: key as NSString, cost: cost)
    }
    
    func removeImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}

struct CollectedItem: Identifiable, Codable {
    let id: UUID
    let object: GameObject
    let imagePath: String?  // Store path instead of data
    let timestamp: Date
    let challengeId: UUID
    
    init(id: UUID = UUID(), object: GameObject, imagePath: String?, timestamp: Date = Date(), challengeId: UUID) {
        self.id = id
        self.object = object
        self.imagePath = imagePath
        self.timestamp = timestamp
        self.challengeId = challengeId
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

