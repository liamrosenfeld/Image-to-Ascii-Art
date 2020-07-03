//
//  PhotoPickerView.swift
//  Image To Ascii Art
//
//  Created by Liam Rosenfeld on 6/30/20.
//  Copyright © 2020 liamrosenfeld. All rights reserved.
//

import SwiftUI
//import PhotosUI
//
//struct PhotoPickerView: UIViewControllerRepresentable {
//    @Environment(\.presentationMode) var presentationMode
//    @Binding var image: UIImage?
//
//    func makeUIViewController(context: Context) -> PHPickerViewController {
//        var configuration = PHPickerConfiguration()
//        configuration.filter = .images
//        configuration.selectionLimit = 1
//
//        let picker = PHPickerViewController(configuration: configuration)
//        picker.delegate = context.coordinator
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: PHPickerViewControllerDelegate {
//        let parent: PhotoPickerView
//
//        init(_ parent: PhotoPickerView) {
//            self.parent = parent
//        }
//
//        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//            parent.presentationMode.wrappedValue.dismiss()
//            if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
//                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
//                    DispatchQueue.main.async {
//                        guard let self = self, let image = image as? UIImage else { return }
//                        self.parent.image = image
//                    }
//                }
//            }
//        }
//    }
//}

import UIKit

struct PhotoPickerView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: PhotoPickerView

        init(_ parent: PhotoPickerView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let taken = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.image = taken
            }

            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
