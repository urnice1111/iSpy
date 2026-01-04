import AVFoundation
import UIKit
import SwiftUI

final class CameraService: NSObject, ObservableObject, @unchecked Sendable {
    @Published var session = AVCaptureSession()
    @Published var alert = false
    @Published var output = AVCapturePhotoOutput()
    @Published var preview: AVCaptureVideoPreviewLayer?
    @Published var isTaken = false
    @Published var capturedImage: UIImage?
    
    private var videoDevice: AVCaptureDevice?  // camera device for zoom
    
    // Zoom bounds and state
    var minZoomFactor: CGFloat { 1.0 }
    var maxZoomFactor: CGFloat {
        guard let device = videoDevice else { return 1.0 }
        // Clamp to a reasonable upper bound to avoid excessive digital zoom
        return min(5.0, device.activeFormat.videoMaxZoomFactor)
    }
    
    var currentZoomFactor: CGFloat {
        videoDevice?.videoZoomFactor ?? 1.0
    }
    
    // Set zoom synchronously (no ramp) on the session queue
    func setZoom(factor: CGFloat) {
        sessionQueue.async { [weak self] in
            guard let self = self, let device = self.videoDevice else { return }
            let clamped = max(self.minZoomFactor, min(factor, self.maxZoomFactor))
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = clamped
                device.unlockForConfiguration()
            } catch {
                print("Failed to set zoom: \(error)")
            }
        }
    }
    
    // Smoothly ramp to a zoom factor
    func rampZoom(to factor: CGFloat, withRate rate: Float = 4.0) {
        sessionQueue.async { [weak self] in
            guard let self = self, let device = self.videoDevice else { return }
            let clamped = max(self.minZoomFactor, min(factor, self.maxZoomFactor))
            do {
                try device.lockForConfiguration()
                device.ramp(toVideoZoomFactor: clamped, withRate: rate)
                device.unlockForConfiguration()
            } catch {
                print("Failed to ramp zoom: \(error)")
            }
        }
    }
    
    func resetZoom() {
        setZoom(factor: 1.0)
    }
    
    private var isSessionRunning = false
    private var isConfigured = false
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUp()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] status in
                if status {
                    self?.setUp()
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async { [weak self] in
                self?.alert = true
            }
        @unknown default:
            break
        }
    }
    
    func setUp() {
        guard !isConfigured else { return }
        
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            do {
                self.session.beginConfiguration()
                
                guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                    self.session.commitConfiguration()
                    return
                }
                
                self.videoDevice = device
                
                let input = try AVCaptureDeviceInput(device: device)
                
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                }
                
                if self.session.canAddOutput(self.output) {
                    self.session.addOutput(self.output)
                }
                
                self.session.commitConfiguration()
                self.isConfigured = true
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func startSession() {
        sessionQueue.async { [weak self] in
            guard let self = self, !self.isSessionRunning else { return }
            self.session.startRunning()
            self.isSessionRunning = true
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self, self.isSessionRunning else { return }
            self.session.stopRunning()
            self.isSessionRunning = false
        }
    }
    
    func takePicture() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        }
    }
    
    func reTake() {
        DispatchQueue.main.async { [weak self] in
            self?.isTaken = false
            self?.capturedImage = nil
        }
        startSession()
    }
    
    func prepareForCoreML() -> UIImage? {
        guard let image = capturedImage else { return nil }
        
        // Resize image for CoreML (typically 224x224 or 299x299)
        let targetSize = CGSize(width: 224, height: 224)
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
    func cleanup() {
        stopSession()
        DispatchQueue.main.async { [weak self] in
//            self?.capturedImage = nil
            self?.preview = nil
//            self?.isTaken = false
        }
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil {
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else { return }
        let image = UIImage(data: imageData)
        
        DispatchQueue.main.async { [weak self] in
            self?.capturedImage = image
            self?.isTaken = true
        }
        stopSession()
    }
}

