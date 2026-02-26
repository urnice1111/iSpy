import SwiftUI
import PencilKit

struct DrawingCanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    var inkColor: UIColor
    var isErasing: Bool
    var onDrawingChanged: ((PKDrawing) -> Void)?
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawing = drawing
        canvas.drawingPolicy = .anyInput
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.delegate = context.coordinator
        canvas.overrideUserInterfaceStyle = .light
        updateTool(canvas)
        return canvas
    }
    
    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        updateTool(canvas)
        if canvas.drawing != drawing {
            canvas.drawing = drawing
        }
    }
    
    private func updateTool(_ canvas: PKCanvasView) {
        if isErasing {
            canvas.tool = PKEraserTool(.vector)
        } else {
            canvas.tool = PKInkingTool(.pen, color: inkColor, width: 15)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onDrawingChanged: onDrawingChanged, drawingBinding: $drawing)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var onDrawingChanged: ((PKDrawing) -> Void)?
        var drawingBinding: Binding<PKDrawing>
        
        init(onDrawingChanged: ((PKDrawing) -> Void)?, drawingBinding: Binding<PKDrawing>) {
            self.onDrawingChanged = onDrawingChanged
            self.drawingBinding = drawingBinding
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            drawingBinding.wrappedValue = canvasView.drawing
            onDrawingChanged?(canvasView.drawing)
        }
    }
}
