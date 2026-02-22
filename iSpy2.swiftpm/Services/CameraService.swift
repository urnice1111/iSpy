import AVFoundation
import UIKit
import SwiftUI

@available(iOS 17.0, *)
final class CameraService: NSObject, ObservableObject, @unchecked Sendable {
    @Published var session = AVCaptureSession()
    @Published var alert = false
    @Published var output = AVCapturePhotoOutput()
    @Published var preview: AVCaptureVideoPreviewLayer?
    @Published var isTaken = false
    @Published var capturedImage: UIImage?
    
    private var videoDevice: AVCaptureDevice?
    
    var minZoomFactor: CGFloat { 1.0 }
    var maxZoomFactor: CGFloat {
        guard let device = videoDevice else { return 1.0 }
        return min(5.0, device.activeFormat.videoMaxZoomFactor)
    }
    
    var currentZoomFactor: CGFloat {
        videoDevice?.videoZoomFactor ?? 1.0
    }
    
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
    
    func takePicture(interfaceOrientation: UIInterfaceOrientation = .landscapeRight) {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            if let connection = self.output.connection(with: .video) {
                let angle: CGFloat = switch interfaceOrientation {
                case .landscapeLeft: 180
                case .landscapeRight: 0
                case .portrait: 90
                case .portraitUpsideDown: 270
                default: 0
                }
                if connection.isVideoRotationAngleSupported(angle) {
                    connection.videoRotationAngle = angle
                }
            }
            
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        }
        
        print("Foto tomada")
    }
    
    func reTake() {
        DispatchQueue.main.async { [weak self] in
            self?.isTaken = false
            self?.capturedImage = nil
        }
        startSession()
    }
    
    func cleanup() {
        stopSession()
        DispatchQueue.main.async { [weak self] in
            self?.preview = nil
        }
    }
}

@available(iOS 17.0, *)
extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil { return }
        
        guard let imageData = photo.fileDataRepresentation() else { return }
        let image = UIImage(data: imageData)
        
        DispatchQueue.main.async { [weak self] in
            self?.capturedImage = image
            self?.isTaken = true
        }
        stopSession()
    }
}
