//
//  SelectImage.swift
//  iMessageExtension
//
//  Created by Liam on 6/30/18.
//  Copyright © 2018 Liam Rosenfeld. All rights reserved.
//

import UIKit

extension ExpandedViewController: UIImagePickerControllerDelegate {
    func pickImage() {
        ImagePickerController.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        self.show(ImagePickerController, sender: self)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            displayImage(image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func takePicture() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            ImagePickerController.delegate = self
            ImagePickerController.sourceType = .camera
            self.show(ImagePickerController, sender: self)
        } else {
            alert(title: "No Camera Available", message: nil, dismissText: "OK")
            print("Camera not avaliable :(")
        }
    }
    
    func selectAnother() {
        self.show(ImagePickerController, sender: self)
    }
}
