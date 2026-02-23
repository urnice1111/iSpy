import Foundation
import SwiftUI
import UIKit

struct CollectedItem: Identifiable, Codable {
    let id: UUID
    let object: GameObject
//    let imagePath: String?  // Store path instead of data
    let timestamp: Date
    let challengeId: UUID
    var aiDescription: String?  // AI-generated description (cached, deprecated)
    var quizBonusPoints: Int?  // Bonus points from quiz (nil = not completed)
    
    init(id: UUID = UUID(), object: GameObject, timestamp: Date = Date(), challengeId: UUID, aiDescription: String? = nil, quizBonusPoints: Int? = nil) {
        self.id = id
        self.object = object
//        self.imagePath = imagePath
        self.timestamp = timestamp
        self.challengeId = challengeId
        self.aiDescription = aiDescription
        self.quizBonusPoints = quizBonusPoints
    }
    
//    var image: Image? {
//        guard let imagePath = imagePath else { return nil }
//        
//        // Check cache first
//        if let cachedImage = ImageCache.shared.image(forKey: imagePath) {
//            return Image(uiImage: cachedImage)
//        }
//        
//        // Load from disk and cache
//        let url = CollectedItem.imagesDirectory.appendingPathComponent(imagePath)
//        guard let data = try? Data(contentsOf: url),
//              let uiImage = UIImage(data: data) else {
//            return nil
//        }
//        
//        // Store in cache for future access
//        ImageCache.shared.setImage(uiImage, forKey: imagePath)
//        
//        return Image(uiImage: uiImage)
//    }
    
//    // Directory for storing images
//    static var imagesDirectory: URL {
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        let imagesDir = paths[0].appendingPathComponent("CollectedImages")
//        
//        // Create directory if it doesn't exist
//        if !FileManager.default.fileExists(atPath: imagesDir.path) {
//            try? FileManager.default.createDirectory(at: imagesDir, withIntermediateDirectories: true)
//        }
//        
//        return imagesDir
//    }
//    
//    // Save image to file system and return the filename
//    static func saveImage(_ imageData: Data) -> String? {
//        let filename = UUID().uuidString + ".jpg"
//        let url = imagesDirectory.appendingPathComponent(filename)
//        
//        do {
//            try imageData.write(to: url)
//            return filename
//        } catch {
//            print("Error saving image: \(error)")
//            return nil
//        }
//    }
}

