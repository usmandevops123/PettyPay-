import SwiftUI
import VisionKit

/// Simple wrapper for VNDocumentCameraViewController
struct DocumentCameraView: UIViewControllerRepresentable {
    typealias Completion = (UIImage?) -> Void
    let completion: Completion

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let vc = VNDocumentCameraViewController()
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var parent: DocumentCameraView
        init(_ parent: DocumentCameraView) { self.parent = parent }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            controller.dismiss(animated: true)

            guard scan.pageCount > 0 else {
                parent.completion(nil)
                return
            }

            // Use the first page for now; extend to iterate pages if needed
            let image = scan.imageOfPage(at: 0)
            parent.completion(image)
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true)
            parent.completion(nil)
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            controller.dismiss(animated: true)
            parent.completion(nil)
        }
    }
}

