import UIKit
import CoreML
import Vision

class ObjectDetectionService {
    
    // The Vision CoreML model
    private var visionModel: VNCoreMLModel?
    
    // Track if model is ready
    private(set) var isModelReady: Bool = false
    
    // Confidence threshold - adjust this value (0.0 to 1.0)
    // Lower = more detections but more false positives
    // Higher = fewer detections but more accurate
    var confidenceThreshold: Float = 0.5
    
    @available(iOS 17.0, *)
    init() {
        // Load model asynchronously to avoid blocking the main thread
        setupModelAsync()
    }
    
    /// Setup the CoreML model asynchronously to avoid UI freezing
    @available(iOS 17.0, *)
    private func setupModelAsync() {
        nonisolated(unsafe) let weakSelf = self
        DispatchQueue.global(qos: .userInitiated).async {
            let config = MLModelConfiguration()
            config.computeUnits = .cpuAndGPU

            do {
                
                // Change the name for the model in later iterations until the final model is done. This is a reminder for you, Emiliano.
                let coreMLModel = try MultiLabelModelISpy(configuration: config)
                let model = coreMLModel.model
                let visionModel = try VNCoreMLModel(for: model)
                
                DispatchQueue.main.async {
                    weakSelf.visionModel = visionModel
                    weakSelf.isModelReady = true
                    print("CoreML model loaded successfully!")
                }
            } catch {
                print("❌ Failed to load CoreML model: \(error)")
                DispatchQueue.main.async {
                    weakSelf.visionModel = nil
                    weakSelf.isModelReady = false
                }
            }
        }
    }
    
    /// Detect objects in an image using the CoreML model
    /// - Parameter image: The UIImage to analyze
    /// - Returns: Array of detected object labels
    func detectObjects(in image: UIImage) -> [String] {
        // If no model is loaded, return empty (or mock data for testing)
        guard let model = visionModel else {
            print("⚠️ No model loaded - returning empty results")
            // Uncomment below to return mock data for testing UI:
            // return mockDetection()
            return []
        }
        
        guard let cgImage = image.cgImage else {
            print("❌ Could not get CGImage from UIImage")
            return []
        }
        
        var detectedObjects: [String] = []
        
        // Create the Vision request
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Vision request error: \(error)")
                return
            }
            
            // Process results
            if let results = request.results as? [VNClassificationObservation] {
                // Filter by confidence threshold
                let validResults = results.filter { $0.confidence >= self.confidenceThreshold }
                
                // Get the labels
                detectedObjects = validResults.map { $0.identifier }
                
                // Debug logging
                print("🔍 Detected \(validResults.count) objects above threshold \(self.confidenceThreshold):")
                for result in validResults {
                    print("   - \(result.identifier): \(String(format: "%.2f", result.confidence * 100))%")
                }
            }
        }
        
        // Configure the request
        request.imageCropAndScaleOption = .centerCrop
        
        // Create handler and perform request
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print("❌ Failed to perform Vision request: \(error)")
        }
        
        return detectedObjects
    }
    
    /// Check if a specific object was found in the detection results
    /// Uses flexible matching (case-insensitive, partial matches)
    func checkIfObjectFound(_ objectName: String, in detectedObjects: [String]) -> Bool {
        let lowerObjectName = objectName.lowercased()
        
        return detectedObjects.contains { detectedObject in
            let lowerDetected = detectedObject.lowercased()
            
            // Exact match
            if lowerDetected == lowerObjectName {
                return true
            }
            
            // Partial match (detected contains object name or vice versa)
            if lowerDetected.contains(lowerObjectName) || lowerObjectName.contains(lowerDetected) {
                return true
            }
            
            // Word-by-word match (for multi-word labels)
            let objectWords = lowerObjectName.split(separator: " ")
            let detectedWords = lowerDetected.split(separator: " ")
            
            for objectWord in objectWords {
                for detectedWord in detectedWords {
                    if objectWord == detectedWord {
                        return true
                    }
                }
            }
            
            return false
        }
    }
    
    /// Get all detections with their confidence scores
    func detectObjectsWithConfidence(in image: UIImage) -> [(label: String, confidence: Float)] {
        guard let model = visionModel,
              let cgImage = image.cgImage else {
            return []
        }
        
        var results: [(label: String, confidence: Float)] = []
        
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let self = self else { return }
            
            if let observations = request.results as? [VNClassificationObservation] {
                results = observations
                    .filter { $0.confidence >= self.confidenceThreshold }
                    .map { ($0.identifier, $0.confidence) }
            }
        }
        
        request.imageCropAndScaleOption = .centerCrop
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
        
        return results
    }
    
    // MARK: - Mock Data for Testing
    
    /// Returns mock detection results for testing the UI without a model
    private func mockDetection() -> [String] {
        // Randomly return some objects for testing
        let possibleObjects = ["Car", "Tree", "Road", "Sky", "Building", "Traffic Sign"]
        let count = Int.random(in: 0...3)
        return Array(possibleObjects.shuffled().prefix(count))
    }
}

