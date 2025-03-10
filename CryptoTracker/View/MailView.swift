//
//  MailView.swift
//  CryptoTracker
//
//  Created by Michael Danylchuk on 3/9/25.
//
import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
    @Binding var toEmail: String
    @Binding var subject: String
    @Binding var body: String
    @Binding var isShowing: Bool

    var attachmentData: Data?
    var attachmentMimeType: String?
    var attachmentFileName: String?

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView

        init(_ parent: MailView) {
            self.parent = parent
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            controller.dismiss(animated: true) {
                self.parent.isShowing = false
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients([toEmail])
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: false)

        // Add an attachment if available
        if let data = attachmentData {
            let mimeType = attachmentMimeType ?? "image/png"
            let fileName = attachmentFileName ?? "screenshot.png"
            vc.addAttachmentData(data, mimeType: mimeType, fileName: fileName)
        }

        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    
    // This is the key fix:
    typealias UIViewControllerType = UIImagePickerController
    typealias Coordinator = ImagePickerCoordinator
    
    let mediaTypes: [String]
    var onPicked: (URL?) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.mediaTypes = mediaTypes
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Nothing to update in this example
    }
    
    func makeCoordinator() -> ImagePickerCoordinator {
        ImagePickerCoordinator(self)
    }
}

// Because we renamed the class to `ImagePickerCoordinator`,
// the typealias above can reference it properly.
class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    let parent: ImagePicker
    
    init(_ parent: ImagePicker) {
        self.parent = parent
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        var pickedURL: URL?
        
        if let mediaURL = info[.mediaURL] as? URL {
            // User picked a video
            pickedURL = mediaURL
        } else if let imageURL = info[.imageURL] as? URL {
            // User picked an image
            pickedURL = imageURL
        }
        
        parent.onPicked(pickedURL)
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        parent.onPicked(nil)
        picker.dismiss(animated: true)
    }
}
