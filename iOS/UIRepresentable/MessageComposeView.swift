//
//  MessageComposeView.swift
//  Image To Ascii Art
//
//  Created by Liam Rosenfeld on 7/16/20.
//  Copyright © 2020 liamrosenfeld. All rights reserved.
//

import UIKit
import SwiftUI
import MessageUI
import Messages
import Combine

struct MessageComposeView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    let message: MSMessage
    @Binding var sent: Bool
    
    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let vc = MFMessageComposeViewController()
        vc.messageComposeDelegate = context.coordinator
        vc.message = message
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        let parent: MessageComposeView
        
        init(_ parent: MessageComposeView) {
            self.parent = parent
        }
        
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            parent.presentationMode.wrappedValue.dismiss()
            
            if result == .sent {
                parent.sent = true
            }
        }
    }
}
