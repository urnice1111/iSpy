import SwiftUI
import AVFoundation

@available(iOS 17.0, *)
struct GameView: View {
    @StateObject private var cameraService = CameraService()
    @State private var detectionService = ObjectDetectionService()
    var gameState: GameState
    @State private var timeRemaining: TimeInterval = 1800 // 30 minutes in seconds
    @State private var timer: Timer?
    @State private var showingCompletionAlert = false
    @State private var showingProcessingAlert = false
    @State private var showingEndGameAlert = false
    @State private var processingMessage = ""
    @State private var isProcessingPhoto = false  // Prevents double-tap and shows loading
    @Environment(\.dismiss) var dismiss
    
    var challenge: GameChallenge? {
        gameState.currentChallenge
    }
    
    var body: some View {
        ZStack {
            if cameraService.isTaken {
                // Show captured image
                if let image = cameraService.capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                }
            } else {
                // Camera preview
                CameraPreview(camera: cameraService)
                    .ignoresSafeArea()
            }
            
            // Overlay UI
            VStack {
                // Timer and header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Time Remaining")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                        Text(timeString(from: timeRemaining))
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    
                    Button {
                        showingEndGameAlert = true
                    } label : {
                        Text("End")
                            .foregroundStyle(Color.red)
                    }
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            
                            .font(.system(size: 30))
                            .foregroundStyle(.white)
//                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                            .font(.system(size: 20, weight: .bold)) // Slightly smaller font feels more "premium"
                                    .foregroundStyle(.white.opacity(0.8))
                                    .padding(12) // Give the icon some breathing room
                                    .background {
                                        Circle()
                                            .fill(.ultraThinMaterial) // The core glass effect
//                                            .environment(\.colorScheme, .dark) // Forces a dark glass look
                                    }
                                    .overlay {
                                        // This creates the "edge" of the glass
                                        Circle()
                                            .stroke(.white.opacity(0.2), lineWidth: 0.5)
                                    }
                                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.black.opacity(0.6), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                Spacer()
                
                // Objects list
                if let challenge = challenge {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(challenge.objectsToFind) { object in
                                ObjectStatusCard(
                                    object: object,
                                    isFound: challenge.isObjectFound(object)
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                }
                
                // Capture button area
                VStack(spacing: 15) {
                    if cameraService.isTaken {
                        HStack(spacing: 20) {
                            Button {
                                cameraService.reTake()
                            } label: {
                                Text("Retake")
                                    .font(.title3)
                                    .bold()
                                    .foregroundStyle(.white)
                                    .frame(width: 120, height: 50)
                                    .background(Color.gray.opacity(0.7))
                                    .clipShape(Capsule())
                            }
                            
                            Button {
                                processPhoto()
                            } label: {
                                HStack(spacing: 8) {
                                    if isProcessingPhoto {
                                        ProgressView()
                                            .tint(.white)
                                    }
                                    Text(isProcessingPhoto ? "Analyzing..." : "Check Object")
                                }
                                .font(.title3)
                                .bold()
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(isProcessingPhoto ? Color.blue.opacity(0.6) : Color.blue)
                                .clipShape(Capsule())
                            }
                            .disabled(isProcessingPhoto)
                        }
                        .padding(.horizontal)
                    } else {
                        Button {
                            cameraService.takePicture()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 70, height: 70)
                                
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                                    .frame(width: 80, height: 80)
                            }
                        }
                        .padding(.bottom, 30)
                    }
                }
                .padding()
//                .background(
//                    LinearGradient(
//                        colors: [Color.clear, Color.black.opacity(0.6)],
//                        startPoint: .top,
//                        endPoint: .bottom
//                    )
//                )
            }
        }
        .onAppear {
            setupCamera()
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        
        .alert("Processing Photo",
               isPresented: $showingProcessingAlert
        ){
            Button("OK", role: .cancel) { }
        } message: {
            Text(processingMessage)
        }
        
        .alert("End game?", isPresented: $showingEndGameAlert){
            Button("End", role: .destructive){
                gameState.finishChallenge()
                dismiss()
            }
            
            Button("Cancel", role: .cancel){}
        } message: {
            Text("The game will be ended and you will be redirected to the main menu.")
        }
        
        .alert("Challenge Complete!", isPresented: $showingCompletionAlert) {
            Button("OK") {
                gameState.finishChallenge()
                dismiss()
            }
        } message: {
            if let challenge = challenge {
                if challenge.isCompleted {
                    Text("Congratulations! You found all \(challenge.objectsToFind.count) objects!")
                } else if challenge.isExpired {
                    Text("Time's up! You found \(challenge.foundObjects.count) out of \(challenge.objectsToFind.count) objects.")
                }
            }
        }
    }
    
    private func setupCamera() {
        cameraService.checkCameraPermission()
    }
    
    private func startTimer() {
        // Stop any existing timer first
        stopTimer()
        
        if let challenge = challenge {
            timeRemaining = challenge.remainingTime
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak gameState] _ in
            guard let gameState = gameState,
                  let challenge = gameState.currentChallenge else {
                DispatchQueue.main.async {
                    timer?.invalidate()
                    timer = nil
                }
                return
            }
            
            // Calculate remaining time without modifying gameState
            let elapsed = Date().timeIntervalSince(challenge.startTime)
            let total = TimeInterval(challenge.durationMinutes * 60)
            let remaining = max(0, total - elapsed)
            
            DispatchQueue.main.async {
                // Only update local state for timer display - avoids full view tree rebuild
                timeRemaining = remaining
                
                // Only update gameState when there's a meaningful state change
                if remaining <= 0 && !challenge.isExpired && !challenge.isCompleted {
                    var expiredChallenge = challenge
                    expiredChallenge.checkExpiration()
                    gameState.currentChallenge = expiredChallenge
                    timer?.invalidate()
                    timer = nil
                    showingCompletionAlert = true
                } else if challenge.isCompleted {
                    timer?.invalidate()
                    timer = nil
                    showingCompletionAlert = true
                }
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func processPhoto() {
        guard let image = cameraService.capturedImage,
              let challenge = gameState.currentChallenge,
              !isProcessingPhoto else {
            return
        }
        
        // Set processing state immediately on main thread
        isProcessingPhoto = true
        
        // Prepare image for CoreML (quick operation, can stay on main thread)
        let preparedImage = cameraService.prepareForCoreML() ?? image
        
        // Capture detection service reference for background work
        let detectionService = self.detectionService
        
        // Run ML inference on background thread to keep UI responsive
        DispatchQueue.global(qos: .userInitiated).async {
            // Heavy ML work happens here - OFF the main thread
            let detectedObjects = detectionService.detectObjects(in: preparedImage)
            
            // Check if any of the detected objects match objects we're looking for
            var foundObject: GameObject? = nil
            for object in challenge.objectsToFind {
                if !challenge.isObjectFound(object) {
                    if detectionService.checkIfObjectFound(object.name, in: detectedObjects) {
                        foundObject = object
                        break
                    }
                }
            }
            
            // Update UI back on main thread
            DispatchQueue.main.async { [self] in
                if let object = foundObject {
                    // Object found!
                    let imageData = image.jpegData(compressionQuality: 0.8)
                    gameState.completeObject(object, imageData: imageData)
                    
                    processingMessage = "Found: \(object.name)! +\(object.points) points"
                    showingProcessingAlert = true
                } else {
                    processingMessage = "No matching objects found. Keep looking!"
                    showingProcessingAlert = true
                }
                
                isProcessingPhoto = false
                
                // Check if challenge is complete
                if let updatedChallenge = gameState.currentChallenge, updatedChallenge.isCompleted {
                    stopTimer()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        showingProcessingAlert = false
                        showingCompletionAlert = true
                    }
                } else {
                    // Reset camera after processing
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        showingProcessingAlert = false
                        cameraService.reTake()
                    }
                }
            }
        }
    }
}

struct CameraPreview: UIViewControllerRepresentable {
    @ObservedObject var camera: CameraService
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.camera = camera
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

class CameraViewController: UIViewController {
    var camera: CameraService!
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layer = AVCaptureVideoPreviewLayer(session: camera.session)
        layer.frame = view.bounds
        layer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(layer)
        previewLayer = layer
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Set published properties after view is fully loaded to avoid "publishing during view update"
        camera.preview = previewLayer
        camera.startSession()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        camera.cleanup()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        previewLayer?.removeFromSuperlayer()
        previewLayer = nil
    }
}

struct ObjectStatusCard: View {
    let object: GameObject
    let isFound: Bool
    
    var difficultyColor: Color {
        switch object.difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isFound ? Color.green : Color.white.opacity(0.3))
                    .frame(width: 50, height: 50)
                
                if isFound {
                    Image(systemName: "checkmark")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Text(String(object.name.prefix(1)))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            
            Text(object.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white)
                .lineLimit(1)
                .frame(width: 70)
            
            Text("\(object.points) pts")
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isFound ? Color.green.opacity(0.3) : Color.black.opacity(0.4))
        )
    }
}

#Preview {
    if #available(iOS 17.0, *) {
        GameView(gameState: GameState())
    } else {
        // Fallback on earlier versions
    }
}

