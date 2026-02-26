import SwiftUI
import UIKit

struct CameraView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        // This is the key line that forces the live camera instead of the gallery
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No updates needed here
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(picker: self)
    }
    
    // The Coordinator handles the communication back to SwiftUI when a picture is taken
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var picker: CameraView
        
        init(picker: CameraView) {
            self.picker = picker
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                self.picker.selectedImage = image
            }
            self.picker.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.picker.dismiss()
        }
    }
}
