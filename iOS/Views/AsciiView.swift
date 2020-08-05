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
import Combine

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
                    ZoomableText(text: ascii, frame: proxy.frame(in: .local))
                        .ignoresSafeArea(.all, edges: .horizontal)
                }
            } else {
                ProgressView("Converting")
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                shareButton.background(
                    GeometryReader { proxy in
                        Color.clear.onAppear {
                            shareButtonFrame = proxy.frame(in: .global)
                        }
                    }
                )
            }
        }
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
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            let asciiArt = AsciiArtist.createAsciiArt(image: image!)
            DispatchQueue.main.async {
                ascii = asciiArt
            }
        }
    }
    
    // MARK: - Alerts
    enum AlertType: Identifiable {
        case shared
        case shareFailed
        case uploadFailed
        
        var id: AlertType { self }
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
        }
    }
    
    // MARK: - Sharing
    var shareButton: some View {
        Menu {
            if let ascii = ascii {
                Button("Text") { showShareSheet(content: ascii) }
                Button("Image") { showShareSheet(content: ascii.toImage(withFont: AsciiArtist.font)) }
                
                if MFMessageComposeViewController.canSendText() {
                    Button("iMessage", action: sendMessageExtension)
                }
            }
        } label: {
            Image(systemName: "square.and.arrow.up")
                .font(Font.title3)
                .foregroundColor(.white)
        }.accessibility(label: Text("Share"))
    }
    
    func sendMessageExtension() {
        MSMessage.messageFromAscii(ascii!, font: AsciiArtist.font) { result in
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
