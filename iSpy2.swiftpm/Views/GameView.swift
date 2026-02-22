import SwiftUI
import CoreML
import AVFoundation

@available(iOS 17.0, *)
struct GameView: View {
    @StateObject private var cameraService = CameraService()
    var gameState: GameState
    @State private var timeRemaining: TimeInterval = 1800
    @State private var timer: Timer?
    @State private var showingCompletionAlert = false
    @State private var showingEndGameAlert = false
    @State private var mlModel: MultiLabelModel?
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
//            Button {
//                showingEndGameAlert = true
//            } label: {
//                Image(systemName: "xmark.circle.fill")
//                    .font(.system(size: 28))
//                    .foregroundStyle(.white)
//                    .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
//            }
            
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
                    .overlay(
                        Capsule()
                            .stroke(.white.opacity(0.15), lineWidth: 0.5)
                    )
            }
            
            Button {
                popToRoot = false
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(10)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.15), lineWidth: 0.5)
                    )
            }
            
        }
        .padding(.horizontal, 16)
        
    }
    
    @ViewBuilder
    private func cloudShape() -> some View {
        Image(systemName: "cloud.fill")
            .font(.system(size: 50))
            .foregroundStyle(.white)
    }
    
    // MARK: - Objects List (right side card)
    
    @ViewBuilder
    private func objectsListView() -> some View {
        if let challenge = challenge {
            VStack(spacing: 10) {
                HStack(spacing: 6) {
                    Image("Star")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                    Text("\(gameState.totalScore)")
                        .font(.custom("FredokaOne-Regular", size: 18))
                        .foregroundStyle(.black)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                
                ForEach(challenge.objectsToFind) { object in
                    let found = challenge.isObjectFound(object)
                    HStack(spacing: 10) {
                        Image(ObjectStatusCard.assetName(for: object))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 44, height: 44)
                        
                        Spacer()
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(found ? Color.green : Color.gray.opacity(0.4), lineWidth: 2)
                                .frame(width: 26, height: 26)
                            
                            if found {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                }
                
                Text(timeString(from: timeRemaining))
                    .font(.custom("FredokaOne-Regular", size: 18))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(.black.opacity(0.35)))
                    .contentTransition(.numericText())
                
            }
            .padding(16)
            .frame(width: 140)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color("ColorOffset"))
                        .offset(y: 4)
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white)
                }
            )
            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        }
    }
    
    // MARK: - Capture Button
    
    @ViewBuilder
    private func captureButtonView() -> some View {
        if !cameraService.isTaken {
            Button {
                let orientation = UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .first?.interfaceOrientation ?? .landscapeRight
                cameraService.takePicture(interfaceOrientation: orientation)
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 80, height: 80)
                        .shadow(color: .orange.opacity(0.5), radius: 6, y: 3)
                    
                    Circle()
                        .stroke(Color.orange.opacity(0.4), lineWidth: 4)
                        .frame(width: 92, height: 92)
                    
                    Image(systemName: "camera.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.white)
                }
            }
            
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
            
            VStack(spacing: 0) {
                HStack{
                    headerView()
                    Spacer()
                }
                
                HStack {
                    VStack {
                        objectsListView()
                            .padding(.top, 16)
                        Spacer()
                    }
                    .padding(.trailing, 16)
                    
                    Spacer()
                    
                    VStack {
                        Spacer()
                        captureButtonView()
                            .padding(.bottom, 24)
                        Spacer()
                    }
                                    
                }
                .padding(.horizontal,20)
            }
        }
        .onAppear {
            cameraService.checkCameraPermission()
            startTimer()
            loadModel()
        }
        .onDisappear {
            stopTimer()
        }
        .onChange(of: cameraService.isTaken) { _, taken in
            if taken {
                processCapture()
                print("processCapture called")
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
        guard let cgImage = cameraService.capturedImage?.cgImage,
              let challenge = gameState.currentChallenge else {
            cameraService.reTake()
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                guard let model = mlModel else {return}
                let input = try MultiLabelModelInput(imageWith: cgImage)
                let output = try model.prediction(input: input)
                
                let matched = challenge.objectsToFind.first { object in
                    !challenge.isObjectFound(object) &&
                    (output.targetProbability[object.name] ?? 0) >= 0.5
                }
                
                DispatchQueue.main.async {
                    if let object = matched {
                        let imageData = cameraService.capturedImage?.jpegData(compressionQuality: 0.8)
                        gameState.completeObject(object, imageData: imageData)
                    } else {
                        // No match — show "not found" feedback, then reset
                    }
                    cameraService.reTake()
                }
            } catch {
                print("ML prediction failed: \(error)")
                DispatchQueue.main.async { cameraService.reTake() }
            }
        }
    }
    
    private func loadModel() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let model = try MultiLabelModel(configuration: MLModelConfiguration())
                DispatchQueue.main.async {
                    self.mlModel = model
                }
            } catch {
                print("Failed to load model: \(error)")
            }
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
    
    static func assetName(for object: GameObject) -> String {
        switch object.name {
        case "Traffic Cone": return "trafficcone"
        case "Fire Hydrant": return "firehydrant"
        case "Bicycle": return "bicycle"
        case "Bus Stop": return "busstop"
        case "Traffic Light": return "trafficlight"
        case "Stop Sign": return "stopsign"
        case "Wind Turbine": return "windturbine"
        case "Electric Tower": return "electrictower"
        case "Traffic Sign": return "trafficsign"
        case "Construction Crane": return "crane"
        case "Gas Station Price Board": return "gasprices"
        case "Police Car": return "policecar"
        case "Ambulance": return "ambulance"
        case "Tractor": return "tractor"
        case "Church": return "church"
        default: return "questionmark.circle"
        }
    }
    
    var body: some View {
        HStack(spacing: 10) {
            Image(Self.assetName(for: object))
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
            
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isFound ? Color.green : Color.gray.opacity(0.4), lineWidth: 2)
                    .frame(width: 26, height: 26)
                
                if isFound {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.green)
                }
            }
        }
    }
}
