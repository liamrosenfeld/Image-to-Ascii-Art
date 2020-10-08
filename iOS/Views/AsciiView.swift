//
//  AsciiView.swift
//  Image To Ascii Art
//
//  Created by Liam Rosenfeld on 6/30/20.
//  Copyright © 2020 liamrosenfeld. All rights reserved.
//

import SwiftUI
import UIKit
import Messages
import MessageUI

struct AsciiView: View {
    @Binding var image: UIImage?
    @State private var ascii: String?
    
    @State private var alert: AlertType? = nil
    @State private var messageToSend: MSMessage? = nil
    @State private var messageSent = false
    
    @State private var shareButtonFrame: CGRect = .zero

    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()

            if let ascii = ascii {
                GeometryReader { proxy in
                    ZoomableText(text: ascii, size: proxy.frame(in: .local).size)
                        .ignoresSafeArea(.all, edges: .horizontal)
                }
            } else {
                ProgressView("Converting")
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(false)
        .navigationBarItems(trailing:
            shareButton.background(
                GeometryReader { proxy in
                    Color.clear.onAppear {
                        shareButtonFrame = proxy.frame(in: .global)
                    }
                }
            )
        )
        .onAppear(perform: generateAscii)
        .alert(item: $alert, content: matchAlert)
        .sheet(item: $messageToSend, onDismiss: {
            if messageSent {
                alert = .shared
                messageSent = false
            }
        }, content: { message in
            MessageComposeView(message: message, sent: $messageSent)
        })
    }
    
    func generateAscii() {
        DispatchQueue.global(qos: .userInitiated).async {
            let asciiArt = AsciiArtist.createAsciiArt(image: image!)
            DispatchQueue.main.async {
                ascii = asciiArt
            }
        }
    }
    
    // MARK: - Alerts
    enum AlertType: Int8, Identifiable {
        case shared
        case shareFailed
        case uploadFailed
        case prematureShare
        
        var id: Int8 { self.rawValue }
    }
    
    func matchAlert(alert: AlertType) -> Alert {
        switch alert {
        case .shared:
            return Alert(title: Text("Shared"), dismissButton: .default(Text("Yay!")))
        case .shareFailed:
            return Alert(
                title: Text("Share Failed"),
                message: Text("An error occurred.")
            )
        case .uploadFailed:
            return Alert(
                title: Text("ASCII Art Could Not Be Uploaded"),
                message: Text("Please check your internet connection.")
            )
        case .prematureShare:
            return Alert(
                title: Text("Whoah there!"),
                message: Text("You need to wait for the image to convert before sharing.")
            )
        }
    }
    
    // MARK: - Sharing
    var shareButton: some View {
        Menu {
            Button("Text", action: shareText)
            Button("Image", action: shareImage)
            if MFMessageComposeViewController.canSendText() {
                Button("iMessage", action: sendMessageExtension)
            }
        } label: {
            Image(systemName: "square.and.arrow.up")
                .font(Font.title3)
                .foregroundColor(.white)
        }.accessibility(label: Text("Share"))
    }
    
    func shareText() {
        if let ascii = ascii {
            showShareSheet(content: ascii)
        } else {
            alert = .prematureShare
        }
    }
    
    func shareImage() {
        if let ascii = ascii {
            showShareSheet(content: ascii.toImage(withFont: AsciiArtist.font))
        } else {
            alert = .prematureShare
        }
    }
    
    func sendMessageExtension() {
        guard let ascii = ascii else {
            alert = .prematureShare
            return
        }
        
        MSMessage.messageFromAscii(ascii, font: AsciiArtist.font) { result in
            switch result {
            case .success(let message):
                messageToSend = message
            case .failure(_):
                alert = .uploadFailed
            }
        }
    }

    func showShareSheet<Content>(content: Content) {
        let shareSheet = UIActivityViewController(activityItems: [content], applicationActivities: nil)
        if UIDevice.current.userInterfaceIdiom == .pad {
            shareSheet.popoverPresentationController?.sourceView = UIApplication.shared.windows.first?.rootViewController?.view
            shareSheet.popoverPresentationController?.sourceRect = self.shareButtonFrame
        }
        shareSheet.completionWithItemsHandler = { (_, completed, _, err) in
            if completed {
                if let err = err {
                    print("Share failed: \(err)")
                    alert = .shareFailed
                } else {
                    alert = .shared
                }
            }
        }
        UIApplication.shared.windows.first?.rootViewController?.present(shareSheet, animated: true, completion: nil)
    }
}

struct AsciiView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AsciiView(image: Binding.constant(UIImage(named: "example-image")!))
        }.previewDevice("iPhone 11")
    }
}
