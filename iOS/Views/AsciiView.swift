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
    @State private var showingShareActionSheet = false
    @State private var messageToSend: MSMessage? = nil
    @State private var messageSent = false

    let asciiFont = UIFont(name: "Menlo", size: 7)!

    var body: some View {
        ZStack {
            Color.background
                .edgesIgnoringSafeArea(.all)

            if let ascii = ascii {
                GeometryReader { proxy in
                    ZoomableText(text: ascii, frame: proxy.frame(in: .local))
                        .edgesIgnoringSafeArea(.horizontal)
                }
            } else {
                ProgressView("Converting")
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if ascii != nil {
                        showingShareActionSheet = true
                    } else {
                        alert = .noAscii
                    }
                }, label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.white)
                })
            }
        }
        .onAppear(perform: generateAscii)
        .alert(item: $alert, content: matchAlert)
        .actionSheet(isPresented: $showingShareActionSheet, content: makeActionSheet)
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
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            let asciiArt = AsciiArtist.createAsciiArt(image: image!, font: asciiFont)
            DispatchQueue.main.async {
                ascii = asciiArt
            }
        }
    }
    
    // MARK: - Alerts
    enum AlertType: Identifiable {
        case noAscii
        case shared
        case shareFailed
        case uploadFailed
        
        var id: AlertType { self }
    }
    
    func matchAlert(alert: AlertType) -> Alert {
        switch alert {
        case .noAscii:
            return Alert(
                title: Text("Whoah There!"),
                message: Text("You have to create some ascii art before you can share it.")
            )
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
    func makeActionSheet() -> ActionSheet {
        var buttons: [ActionSheet.Button] = [
            .default(Text("Text")) {
                showShareSheet(content: ascii)
            },
            .default(Text("Image")) {
                showShareSheet(content: ascii!.toImage(withFont: asciiFont))
            },
        ]
        
        if MFMessageComposeViewController.canSendText() {
            buttons += [
                .default(Text("iMessage")) {
                    sendMessageExtension()
                },
                .cancel()
            ]
        } else {
            print("SMS services are not available")
            buttons.append(.cancel())
        }
        
        return ActionSheet(title: Text("Share as"), buttons: buttons)
    }
    
    func sendMessageExtension() {
        MSMessage.messageFromAscii(ascii!, font: asciiFont) { result in
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
        AsciiView(image: Binding.constant(UIImage(named: "example-image")!))
            .previewDevice("iPhone 11")
    }
}
