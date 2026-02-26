import SwiftUI
import PencilKit

@available(iOS 26.0, *)
struct ObjectDetailView: View {
    
    var collectedItem: CollectedItem
    @Environment(GameState.self) var gameState
    @Environment(\.dismiss) private var dismiss
    
    @State private var drawing = PKDrawing()
    @State private var placedStickers: [PlacedSticker] = []
    @State private var selectedColor: Color = .black
    @State private var isErasing = false
    @State private var isDrawingActive = true
    @State private var canvasSize: CGSize = .zero
    @State private var saveWorkItem: DispatchWorkItem?
    @State private var isDraggingOverTrash = false
    @State private var trashFrame: CGRect = .zero
    
    private let drawingColors: [(Color, UIColor)] = [
        (.black, .black),
        (.white, .white),
        (.red, .systemRed),
        (.blue, .systemBlue),
        (.green, .systemGreen),
        (.yellow, .systemYellow),
        (.purple, .systemPurple),
    ]
    
    private var currentItem: CollectedItem {
        gameState.collectedItems.first { $0.id == collectedItem.id } ?? collectedItem
    }
    
    private var currentUIColor: UIColor {
        drawingColors.first { $0.0 == selectedColor }?.1 ?? .black
    }
    
    var body: some View {
        ZStack {
            Image("BackgroundOnboarding")
                .resizable()
                .ignoresSafeArea()
            
            HStack(spacing: 0) {
                canvasArea
                stickerSidebar
            }
            
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.leading, 16)
                .padding(.top, 8)
                Spacer()
            }
        }
        .onAppear {
            loadState()
            gameState.isFullScreenActive = true
        }
        .onDisappear {
            gameState.isFullScreenActive = false
        }
        .toolbar(.hidden, for: .tabBar)
        .toolbarVisibility(.hidden, for: .navigationBar)
    }
    
    // MARK: - Canvas Area (Left ~70%)
    
    private var canvasArea: some View {
        VStack(spacing: 12) {
            headerBar
            
            GeometryReader { geo in
                ZStack {
                    photoLayer
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                    
                    DrawingCanvasView(
                        drawing: $drawing,
                        inkColor: currentUIColor,
                        isErasing: isErasing,
                        onDrawingChanged: { _ in debounceSaveDrawing() }
                    )
                    .allowsHitTesting(isDrawingActive)
                    
                    ForEach(placedStickers) { sticker in
                        DraggableStickerView(
                            sticker: sticker,
                            onUpdate: { updated in
                                if let i = placedStickers.firstIndex(where: { $0.id == updated.id }) {
                                    placedStickers[i] = updated
                                    debounceSaveStickers()
                                }
                            },
                            onDelete: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    placedStickers.removeAll { $0.id == sticker.id }
                                }
                                debounceSaveStickers()
                            },
                            onDragChanged: { globalPos in
                                isDraggingOverTrash = trashFrame.contains(globalPos)
                            },
                            onDragEnded: { globalPos in
                                if trashFrame.contains(globalPos) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        placedStickers.removeAll { $0.id == sticker.id }
                                    }
                                    debounceSaveStickers()
                                }
                                isDraggingOverTrash = false
                            }
                        )
                        .allowsHitTesting(!isDrawingActive)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .onAppear { canvasSize = geo.size }
                .onChange(of: geo.size) { _, newSize in canvasSize = newSize }
            }
            
            ZStack {
                drawingToolbar
                
                if !isDrawingActive {
                    HStack {
                        Spacer()
                        trashZone
                    }
                }
            }
        }
        .padding(.leading, 30)
        .padding(.vertical, 16)
        .padding(.trailing, 12)
        .frame(maxWidth: .infinity)
    }
    
    private var headerBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(collectedItem.object.name)
                    .font(.custom("FredokaOne-Regular", size: 32))
                    .foregroundStyle(Color("StatsText"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text("Captured: \(collectedItem.timestamp.formatted(date: .abbreviated, time: .omitted))")
                    .font(.custom("FredokaOne-Regular", size: 14))
                    .foregroundStyle(Color("StatsText").opacity(0.7))
            }
            Spacer()
//            HStack(spacing: 4) {
//                Image("Star")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 34)
//                Text("\(collectedItem.object.points)")
//                    .font(.custom("FredokaOne-Regular", size: 34))
//                    .foregroundStyle(.black)
//            }
        }
    }
    
    @ViewBuilder
    private var photoLayer: some View {
        if let photo = collectedItem.image {
            photo
                .resizable()
                .scaledToFill()
        } else {
            Image(collectedItem.object.imageName)
                .resizable()
                .scaledToFill()
        }
    }
    
    // MARK: - Drawing Toolbar
    
    private var drawingToolbar: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isDrawingActive.toggle()
                }
            } label: {
                Image(systemName: isDrawingActive ? "pencil.tip" : "hand.point.up.fill")
                    .font(.title2)
                    .foregroundStyle(isDrawingActive ? .white : .orange)
                    .frame(width: 50, height: 50)
                    .background(isDrawingActive ? Color.indigo : Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 2)
            }
            
            if isDrawingActive {
                Divider()
                    .frame(height: 36)
                
                ForEach(drawingColors, id: \.1) { color, _ in
                    Circle()
                        .fill(color)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .strokeBorder(.white, lineWidth: selectedColor == color && !isErasing ? 4 : 0)
                        )
                        .shadow(color: selectedColor == color && !isErasing ? color.opacity(0.5) : .clear, radius: 6)
                        .onTapGesture {
                            selectedColor = color
                            isErasing = false
                        }
                }
                
                Divider()
                    .frame(height: 36)
                
                Button {
                    isErasing.toggle()
                } label: {
                    Image(systemName: "eraser.fill")
                        .font(.title2)
                        .foregroundStyle(isErasing ? .white : .black)
                        .frame(width: 50, height: 50)
                        .background(isErasing ? Color.pink : Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 2)
                }
                
                Button {
                    undoDrawing()
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.title2)
                        .foregroundStyle(.yellow)
                        .frame(width: 50, height: 50)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 2)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isDrawingActive)
    }
    
    private var trashZone: some View {
        GeometryReader { geo in
            Color.clear
                .onAppear { trashFrame = geo.frame(in: .global) }
                .onChange(of: geo.frame(in: .global)) { _, newFrame in trashFrame = newFrame }
        }
        .frame(width: 70, height: 70)
        .overlay(
            ZStack {
                Circle()
                    .fill(isDraggingOverTrash ? Color.red : Color.white.opacity(0.9))
                Image(systemName: "trash.fill")
                    .font(.title)
                    .foregroundStyle(isDraggingOverTrash ? .white : .red)
            }
            .frame(width: 60, height: 60)
            .scaleEffect(isDraggingOverTrash ? 1.3 : 1.0)
            .shadow(color: isDraggingOverTrash ? .red.opacity(0.5) : .black.opacity(0.15), radius: isDraggingOverTrash ? 10 : 4)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDraggingOverTrash)
        )
        .padding(.trailing, 10)
    }
    
    // MARK: - Sticker Sidebar (Right ~30%)
    
    private var stickerSidebar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                Image("Star")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36)
                Text("\(gameState.totalScore)")
                    .font(.custom("FredokaOne-Regular", size: 36))
                    .foregroundStyle(.black)
            }
            .padding(.top, 16)
            .padding(.bottom, 8)
            
            Text("Stickers")
                .font(.custom("FredokaOne-Regular", size: 20))
                .foregroundStyle(Color("StatsText"))
                .padding(.bottom, 8)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(StickerCatalog.all) { sticker in
                        stickerCell(sticker)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 20)
            }
        }
        .frame(width: 220)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.trailing, 16)
        .padding(.vertical, 16)
    }
    
    private func stickerCell(_ sticker: StickerDefinition) -> some View {
        let owned = gameState.isStickerPurchased(sticker.id)
        let canAfford = gameState.totalScore >= sticker.price
        
        return Button {
            if owned {
                placeSticker(sticker)
            } else if canAfford {
                let success = gameState.purchaseSticker(sticker)
                if success {
                    placeSticker(sticker)
                }
            }
        } label: {
            VStack(spacing: 4) {
                Image(sticker.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .saturation(owned || canAfford ? 1 : 0.3)
                    .opacity(owned || canAfford ? 1 : 0.5)
                
                if owned {
                    Text("Owned")
                        .font(.custom("FredokaOne-Regular", size: 10))
                        .foregroundStyle(.green)
                } else {
                    HStack(spacing: 2) {
                        Image("Star")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12)
                        Text("\(sticker.price)")
                            .font(.custom("FredokaOne-Regular", size: 12))
                            .foregroundStyle(canAfford ? .orange : .gray)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(owned ? Color.green.opacity(0.1) : .white.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(owned ? Color.green.opacity(0.3) : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .medium), trigger: owned)
    }
    
    // MARK: - Actions
    
    private func placeSticker(_ sticker: StickerDefinition) {
        let center = CGPoint(
            x: canvasSize.width / 2 + CGFloat.random(in: -40...40),
            y: canvasSize.height / 2 + CGFloat.random(in: -40...40)
        )
        let placed = PlacedSticker(
            stickerImageName: sticker.imageName,
            position: center,
            scale: 0.8
        )
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            placedStickers.append(placed)
            isDrawingActive = false
        }
        debounceSaveStickers()
    }
    
    private func loadState() {
        placedStickers = currentItem.placedStickers
        if let data = currentItem.drawingData,
           let restored = try? PKDrawing(data: data) {
            drawing = restored
        }
    }
    
    private func debounceSaveDrawing() {
        saveWorkItem?.cancel()
        let item = DispatchWorkItem { [drawing] in
            gameState.saveDrawing(itemId: collectedItem.id, data: drawing.dataRepresentation())
        }
        saveWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: item)
    }
    
    private func debounceSaveStickers() {
        gameState.savePlacedStickers(itemId: collectedItem.id, stickers: placedStickers)
    }
    
    private func undoDrawing() {
        guard !drawing.strokes.isEmpty else { return }
        var updated = drawing
        updated.strokes.removeLast()
        drawing = updated
        debounceSaveDrawing()
    }
}

// MARK: - Draggable Sticker View

struct DraggableStickerView: View {
    let sticker: PlacedSticker
    var onUpdate: (PlacedSticker) -> Void
    var onDelete: () -> Void
    var onDragChanged: ((CGPoint) -> Void)?
    var onDragEnded: ((CGPoint) -> Void)?
    
    @State private var dragOffset: CGSize = .zero
    @State private var currentScale: CGFloat = 1.0
    @State private var currentRotation: Angle = .zero
    @State private var commitPending = false
    
    var body: some View {
        Image(sticker.stickerImageName)
            .resizable()
            .scaledToFit()
            .frame(width: 80, height: 80)
            .scaleEffect(sticker.scale * currentScale)
            .rotationEffect(.degrees(sticker.rotationDegrees) + currentRotation)
            .offset(x: dragOffset.width, y: dragOffset.height)
            .position(sticker.position)
            .gesture(dragGesture)
            .simultaneousGesture(scaleAndRotateGesture)
    }
    
    private func scheduleCommit() {
        guard !commitPending else { return }
        commitPending = true
        DispatchQueue.main.async {
            commitPending = false
            var updated = sticker
            updated.positionX += dragOffset.width
            updated.positionY += dragOffset.height
            updated.scale = max(0.2, sticker.scale * currentScale)
            updated.rotationDegrees += currentRotation.degrees
            dragOffset = .zero
            currentScale = 1.0
            currentRotation = .zero
            onUpdate(updated)
        }
    }
    
    private var dragGesture: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                dragOffset = CGSize(
                    width: value.location.x - value.startLocation.x,
                    height: value.location.y - value.startLocation.y
                )
                onDragChanged?(value.location)
            }
            .onEnded { value in
                onDragEnded?(value.location)
                dragOffset = CGSize(
                    width: value.location.x - value.startLocation.x,
                    height: value.location.y - value.startLocation.y
                )
                scheduleCommit()
            }
    }
    
    private var scaleAndRotateGesture: some Gesture {
        SimultaneousGesture(
            MagnificationGesture()
                .onChanged { value in
                    currentScale = value
                },
            RotationGesture()
                .onChanged { angle in
                    currentRotation = angle
                }
        )
        .onEnded { value in
            if let scale = value.first {
                currentScale = scale
            }
            if let rotation = value.second {
                currentRotation = rotation
            }
            scheduleCommit()
        }
    }
}

// MARK: - Confetti

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var color: Color
    var size: CGFloat
    var opacity: Double
    var rotation: Double
    var scale: CGFloat
}

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var isAnimating = false
    
    let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange, .mint, .cyan]
    let particleCount = 50
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size * 1.5)
                        .rotationEffect(.degrees(particle.rotation))
                        .scaleEffect(particle.scale)
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                startConfetti(in: geometry.size)
            }
        }
        .ignoresSafeArea()
    }
    
    private func startConfetti(in size: CGSize) {
        for _ in 0..<particleCount {
            let particle = ConfettiParticle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: -50...0)
                ),
                color: colors.randomElement() ?? .blue,
                size: CGFloat.random(in: 6...12),
                opacity: 1.0,
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.8...1.2)
            )
            particles.append(particle)
        }
        
        withAnimation(.easeIn(duration: 0.1)) {
            isAnimating = true
        }
        
        for i in particles.indices {
            let delay = Double.random(in: 0...0.5)
            let duration = Double.random(in: 1.5...3.0)
            let horizontalDrift = CGFloat.random(in: -100...100)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeIn(duration: duration)) {
                    particles[i].position.y = size.height + 50
                    particles[i].position.x += horizontalDrift
                    particles[i].rotation += Double.random(in: 180...720)
                    particles[i].opacity = 0
                }
            }
        }
    }
}

// MARK: - Preview

@available(iOS 26.0, *)
#Preview {
    let state: GameState = {
        let s = GameState()
        s.totalScore = 100
        s.collectedItems = [
            CollectedItem(
                object: GameObject(name: "Traffic Cone", category: "Road", difficulty: .easy),
                challengeId: UUID()
            )
        ]
        return s
    }()
    
    NavigationStack {
        ObjectDetailView(
            collectedItem: state.collectedItems[0]
        )
    }
    .environment(state)
    .previewInterfaceOrientation(.landscapeLeft)
}
