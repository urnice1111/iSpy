import SwiftUI

// MARK: - AI Processing Glow Animation
struct AIProcessingGlow: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Primary rotating gradient
            AngularGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.6, green: 0.2, blue: 0.9),   // Purple
                    Color(red: 0.9, green: 0.3, blue: 0.6),   // Pink
                    Color(red: 1.0, green: 0.5, blue: 0.3),   // Orange
                    Color(red: 1.0, green: 0.8, blue: 0.3),   // Yellow
                    Color(red: 0.3, green: 0.8, blue: 0.5),   // Green
                    Color(red: 0.3, green: 0.5, blue: 0.9),   // Blue
                    Color(red: 0.6, green: 0.2, blue: 0.9),   // Purple (loop)
                ]),
                center: .center,
                startAngle: .degrees(rotation),
                endAngle: .degrees(rotation + 360)
            )
            .blur(radius: 30)
            .scaleEffect(scale)
            
            // Secondary layer for more depth
            AngularGradient(
                gradient: Gradient(colors: [
                    Color.purple.opacity(0.8),
                    Color.pink.opacity(0.8),
                    Color.orange.opacity(0.8),
                    Color.blue.opacity(0.8),
                    Color.purple.opacity(0.8),
                ]),
                center: .center,
                startAngle: .degrees(-rotation * 0.7),
                endAngle: .degrees(-rotation * 0.7 + 360)
            )
            .blur(radius: 50)
            .opacity(0.5)
        }
        .onAppear {
            // Rotation animation
            withAnimation(
                .linear(duration: 4)
                .repeatForever(autoreverses: false)
            ) {
                rotation = 360
            }
            
            // Pulse animation
            withAnimation(
                .easeInOut(duration: 2)
                .repeatForever(autoreverses: true)
            ) {
                scale = 1.1
            }
        }
    }
}

// MARK: - AI Processing Overlay View
/// Full screen overlay with Apple Intelligence style animation
@available(iOS 17.0, *)
struct AIProcessingOverlay: View {
    let message: String
    
    @State private var dotCount = 0
    @State private var timer: Timer?
    
    var animatedDots: String {
        String(repeating: ".", count: dotCount)
    }
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            // Glow effect at edges
            AIProcessingGlow()
                .mask(
                    Canvas { context, size in
                        // Create a frame/border mask
                        let rect = CGRect(origin: .zero, size: size)
                        let innerRect = rect.insetBy(dx: size.width * 0.15, dy: size.height * 0.25)
                        
                        var path = Path(rect)
                        path.addPath(Path(ellipseIn: innerRect))
                        
                        context.fill(path, with: .color(.white))
                    }
                )
                .blur(radius: 20)
            
            // Center content
            VStack(spacing: 24) {
                // Animated icon
                ZStack {
                    // Glowing background
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.purple.opacity(0.4),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    // Icon
                    Image(systemName: "apple.intelligence")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .pink, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .symbolEffect(.pulse, options: .repeating)
                }
                
                // Text
                VStack(spacing: 8) {
                    Text(message + animatedDots)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                    
                    Text("Using on-device ML")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.3),
                                .white.opacity(0.1),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
        }
        .onAppear {
            // Animate dots
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.2)) {
                    dotCount = (dotCount + 1) % 4
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
}

// MARK: - View Modifier
@available(iOS 17.0, *)
struct AIProcessingModifier: ViewModifier {
    let isProcessing: Bool
    let message: String
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isProcessing {
                    AIProcessingOverlay(message: message)
                        .transition(.opacity.combined(with: .scale(scale: 1.1)))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isProcessing)
    }
}

@available(iOS 17.0, *)
extension View {
    /// Adds an Apple Intelligence style processing overlay
    func aiProcessingOverlay(isProcessing: Bool, message: String = "Analyzing") -> some View {
        modifier(AIProcessingModifier(isProcessing: isProcessing, message: message))
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        // Sample background
        Image(systemName: "photo")
            .font(.system(size: 100))
            .foregroundStyle(.gray)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
        
        if #available(iOS 17.0, *) {
            AIProcessingOverlay(message: "Analyzing")
        } else {
            // Fallback on earlier versions
        }
    }
}

