//
//  iMessage.swift
//  ImageToAsciiArt
//
//  Created by Liam on 6/30/18.
//  Copyright © 2018 Liam Rosenfeld. All rights reserved.
//

import Foundation
import Firebase
import MessageUI
import Messages

extension DisplayViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        // Check the result or perform other tasks.
        if result == .sent {
            self.alert(title: "Sent!", message: nil, dismissText: "Yay!")
        }
        
        // Dismiss the message compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
    func sendMessage(with ascii: String) {
        setupFirebase()
        
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self as MFMessageComposeViewControllerDelegate
        
        // Create Message
        composeVC.message = MSMessage()
        composeVC.message?.layout = layout(image: image(from: scrollView)!)
        composeVC.message?.url = getURL(ascii: ascii)
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func layout(image: UIImage) -> MSMessageLayout {
        let layout = MSMessageTemplateLayout()
        layout.image = image
        layout.caption = "Ascii Art"
        return layout
    }
    
    func setupFirebase() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            ref = Database.database().reference()
        }
    }
    
    func getURL(ascii: String) -> URL {
        // Send to Firebase
        if ref == nil {
            ref = Database.database().reference()
        }
        let postArt = self.ref.child("asciiArt").childByAutoId()
        postArt.setValue(ascii)
        let artID = postArt.key
        
        // Get Message URL
        var components = URLComponents()
        let qID = URLQueryItem(name: "artID", value: artID )
        components.queryItems = [qID]
        return components.url!
    }
}
