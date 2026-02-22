import SwiftUI

struct TestView: View {
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    
    var body: some View {
        VStack(spacing: 20) {
            // Display the image if one has been taken
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 400, height: 400)
                    .cornerRadius(10)
                    .overlay(Text("No Image Captured").foregroundColor(.gray))
            }
            
            // Button to open the live camera
            Button(action: {
                showCamera = true
            }) {
                Label("Take Photo", systemImage: "camera")
                    .font(.title2)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        // Present the camera full screen when the button is tapped
        .fullScreenCover(isPresented: $showCamera) {
            CameraView(selectedImage: $capturedImage)
                .ignoresSafeArea()
        }
    }
}
