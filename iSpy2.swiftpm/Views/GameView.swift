import SwiftUI
import AVFoundation

@available(iOS 17.0, *)
struct GameView: View {
    @StateObject private var cameraService = CameraService()
    var gameState: GameState
    @State private var timeRemaining: TimeInterval = 1800
    @State private var timer: Timer?
    @State private var showingCompletionAlert = false
    @State private var showingEndGameAlert = false
    @Environment(\.dismiss) var dismiss
    @Binding var popToRoot: Bool
    
    @State private var isPinching = false
    @State private var initialZoomFactor: CGFloat = 1.0
    
    var challenge: GameChallenge? {
        gameState.currentChallenge
    }
    
    private func clampedZoom(_ factor: CGFloat) -> CGFloat {
        min(max(factor, cameraService.minZoomFactor), cameraService.maxZoomFactor)
    }
    
    // MARK: - Header
    
    @ViewBuilder
    private func headerView() -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Time Remaining")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                Text(timeString(from: timeRemaining))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
            }
            
            Spacer()
            
            Button {
                showingEndGameAlert = true
            } label: {
                Text("End Game")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(Capsule().stroke(.white.opacity(0.15), lineWidth: 0.5))
            }
            
            Button {
                popToRoot = false
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(10)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().stroke(.white.opacity(0.15), lineWidth: 0.5))
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
    }
    
    // MARK: - Objects List
    
    @ViewBuilder
    private func objectsListView() -> some View {
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
    }
    
    // MARK: - Capture Button
    
    @ViewBuilder
    private func captureButtonView() -> some View {
        if !cameraService.isTaken {
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
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            if cameraService.isTaken {
                if let image = cameraService.capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                }
            } else {
                CameraPreview(camera: cameraService)
                    .ignoresSafeArea()
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                if !isPinching {
                                    isPinching = true
                                    initialZoomFactor = cameraService.currentZoomFactor
                                }
                                cameraService.setZoom(factor: clampedZoom(initialZoomFactor * value))
                            }
                            .onEnded { _ in
                                isPinching = false
                            }
                    )
            }
            
            VStack {
                headerView()
                Spacer()
                objectsListView()
                captureButtonView()
                    .padding()
            }
        }
        .onAppear {
            cameraService.checkCameraPermission()
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .onChange(of: cameraService.isTaken) { _, taken in
            if taken {
                processCapture()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .alert("End game?", isPresented: $showingEndGameAlert) {
            Button("End", role: .destructive) {
                gameState.finishChallenge()
                popToRoot = false
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You will return to Home and your current challenge will end.")
        }
        .alert("Challenge Complete!", isPresented: $showingCompletionAlert) {
            Button("OK") {
                gameState.finishChallenge()
                popToRoot = false
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
        .tint(nil)
    }
    
    // MARK: - Capture Processing (placeholder for future ML)
    
    private func processCapture() {
        // TODO: Run ML detection here in the future.
        // For now, just show the captured image briefly then reset.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            cameraService.reTake()
        }
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        stopTimer()
        
        if let challenge = challenge {
            timeRemaining = challenge.remainingTime
        }
        
        nonisolated(unsafe) let gameState = self.gameState
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard let challenge = gameState.currentChallenge else {
                DispatchQueue.main.async {
                    timer?.invalidate()
                    timer = nil
                }
                return
            }
            
            let elapsed = Date().timeIntervalSince(challenge.startTime)
            let total = TimeInterval(challenge.durationMinutes * 60)
            let remaining = max(0, total - elapsed)
            
            DispatchQueue.main.async {
                timeRemaining = remaining
                
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
}

// MARK: - Camera Preview

@available(iOS 17.0, *)
struct CameraPreview: UIViewControllerRepresentable {
    @ObservedObject var camera: CameraService
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.camera = camera
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

@available(iOS 17.0, *)
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
        camera.preview = previewLayer
        camera.startSession()
        applyRotation()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        previewLayer?.frame = view.bounds
        applyRotation()
    }
    
    private func applyRotation() {
        guard let connection = previewLayer?.connection else { return }
        
        let angle: CGFloat
        if let scene = view.window?.windowScene {
            switch scene.interfaceOrientation {
            case .landscapeLeft:
                angle = 180
            case .landscapeRight:
                angle = 0
            default:
                angle = 0
            }
        } else {
            angle = 0
        }
        
        if connection.isVideoRotationAngleSupported(angle) {
            connection.videoRotationAngle = angle
        }
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

// MARK: - Object Status Card

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
