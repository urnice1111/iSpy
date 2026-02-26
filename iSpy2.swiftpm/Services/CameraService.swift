import AVFoundation
import UIKit
import SwiftUI

@available(iOS 17.0, *)
final class CameraService: NSObject, ObservableObject, @unchecked Sendable {
    let session = AVCaptureSession()
    @Published var alert = false
    let output = AVCapturePhotoOutput()
    @Published var preview: AVCaptureVideoPreviewLayer?
    @Published var isTaken = false
    @Published var capturedImage: UIImage?
    @Published private(set) var isReady = false

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
        configQueue.async { [weak self] in
            guard let self, let device = self.videoDevice else { return }
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

    private var isSessionRunning = false
    private var isConfigured = false

    /// Background queue for configuration and device operations only.
    private let configQueue = DispatchQueue(label: "camera.config.queue")

    // MARK: - Permission

    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUp()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted { self?.setUp() }
            }
        case .denied, .restricted:
            DispatchQueue.main.async { [weak self] in self?.alert = true }
        @unknown default:
            break
        }
    }

    // MARK: - Setup (configure only — never calls startRunning)

    func setUp() {
        configQueue.async { [weak self] in
            guard let self, !self.isConfigured else { return }

            self.session.beginConfiguration()
            self.session.sessionPreset = .photo

            var configured = false
            do {
                guard let device = AVCaptureDevice.default(
                    .builtInWideAngleCamera, for: .video, position: .back
                ) else {
                    self.session.commitConfiguration()
                    return
                }
                self.videoDevice = device
                let input = try AVCaptureDeviceInput(device: device)
                if self.session.canAddInput(input)  { self.session.addInput(input) }
                if self.session.canAddOutput(self.output) { self.session.addOutput(self.output) }
                configured = true
            } catch {
                print("CameraService setUp error: \(error.localizedDescription)")
            }
            self.session.commitConfiguration()

            guard configured else { return }
            self.isConfigured = true

            DispatchQueue.main.async { [weak self] in
                self?.isReady = true
            }
        }
    }

    // MARK: - Start / Stop (run on main thread to satisfy AVCaptureSession's internal queue assertion)

    func startSession() {
        let doStart = { [weak self] in
            guard let self, self.isConfigured, !self.isSessionRunning else { return }
            self.session.startRunning()
            self.isSessionRunning = self.session.isRunning
        }
        if Thread.isMainThread {
            doStart()
        } else {
            DispatchQueue.main.async(execute: doStart)
        }
    }

    func stopSession() {
        let doStop = { [weak self] in
            guard let self, self.isSessionRunning else { return }
            self.session.stopRunning()
            self.isSessionRunning = false
        }
        if Thread.isMainThread {
            doStop()
        } else {
            DispatchQueue.main.async(execute: doStop)
        }
    }

    // MARK: - Capture

    func takePicture(interfaceOrientation: UIInterfaceOrientation = .landscapeRight) {
        configQueue.async { [weak self] in
            guard let self else { return }
            if let connection = self.output.connection(with: .video) {
                let angle: CGFloat = switch interfaceOrientation {
                case .landscapeLeft:        180
                case .landscapeRight:       0
                case .portrait:             90
                case .portraitUpsideDown:   270
                default:                    0
                }
                if connection.isVideoRotationAngleSupported(angle) {
                    connection.videoRotationAngle = angle
                }
            }
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        }
    }

    func reTake() {
        DispatchQueue.main.async { [weak self] in
            self?.isTaken = false
            self?.capturedImage = nil
        }
    }

    func cleanup() {
        stopSession()
        DispatchQueue.main.async { [weak self] in self?.preview = nil }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

@available(iOS 17.0, *)
extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard error == nil, let data = photo.fileDataRepresentation() else { return }
        let image = UIImage(data: data)
        DispatchQueue.main.async { [weak self] in
            self?.capturedImage = image
            self?.isTaken = true
        }
        stopSession()
    }
}
