//
//  ReceivedView.swift
//  Image To Ascii Art
//
//  Created by Liam Rosenfeld on 7/12/20.
//  Copyright © 2020 Liam Rosenfeld. All rights reserved.
//

import SwiftUI
import Combine
import UIKit
import Messages

class ReceivedDelegate {
    var makeNew = PassthroughSubject<Void, Never>()
}

struct ReceivedView: View {
    
    // Connection to the outside
    let message: MSMessage
    let delegate: ReceivedDelegate
    var parent: MessagesViewController
    
    // Internal ascii stuff
    private let asciiFont = UIFont(name: "Menlo", size: 7)!
    @State private var ascii: String?
    
    // Showing UI State
    @State private var alert: AlertType? = nil
    
    var body: some View {
        ZStack {
            Color.background
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        delegate.makeNew.send()
                    }, label: {
                        Image(systemName: "arrowshape.turn.up.left")
                            .font(Font.title3.bold())
                            .foregroundColor(.white)
                            .padding(5)
                    })
                    .accessibility(value: Text("Reply with ASCII Art"))
                    .padding(.leading, 10)
                    
                    Spacer()
                    
                    shareButton

                }.frame(minWidth: 0, maxWidth: .infinity).padding(10).background(Color.navBar)
                
                
                if let ascii = ascii {
                    GeometryReader { proxy in
                        ZoomableText(text: ascii, frame: proxy.frame(in: .local))
                    }
                } else {
                    VStack {
                        Spacer()
                        ProgressView("Downloading")
                        Spacer()
                    }
                }
            }
        }
        .alert(item: $alert, content: matchAlert)
        .onAppear(perform: fetchAscii)
    }
    
    var shareButton: some View {
        Menu {
            if let ascii = ascii {
                Button("Text") { showShareSheet(content: ascii) }
                Button("Image") { showShareSheet(content: ascii.toImage(withFont: asciiFont)) }
            }
        } label: {
            Image(systemName: "square.and.arrow.up")
                .font(Font.title3)
                .foregroundColor(.white)
                .padding(.trailing, 10)
                .accessibility(value: Text("Share"))
        }
    }
    
    enum AlertType: Identifiable {
        case downloadFailed
        case notDownloadedYet
        case shared
        case shareFailed
        
        var id: AlertType { self }
    }
    
    func matchAlert(alert: AlertType) -> Alert {
        switch alert {
        case .notDownloadedYet:
            return Alert(
                title: Text("Whoah There!"),
                message: Text("The ASCII Art must download before it can be shared.")
            )
        case .downloadFailed:
            return Alert(
                title: Text("ASCII Art Could Not Be Downloaded"),
                message: Text("Please check your internet connection.")
            )
        case .shared:
            return Alert(
                title: Text("Shared"),
                dismissButton: .default(Text("Yay!"))
            )
        case .shareFailed:
            return Alert(
                title: Text("Share Failed"),
                message: Text("An error occurred.")
            )
        }
    }
    
    func fetchAscii() {
        ascii = nil
        message.toAscii { fetchedAscii in
            if let fetchedAscii = fetchedAscii {
                ascii = fetchedAscii
            } else {
                alert = .downloadFailed
            }
        }
    }
    
    func showShareSheet<Content>(content: Content) {
        let shareSheet = UIActivityViewController(activityItems: [content], applicationActivities: nil)
        shareSheet.completionWithItemsHandler = { (_, completed, _, err) in
            if completed {
                if let err = err {
                    print("Share failed \(err)")
                    alert = .shareFailed
                } else {
                    alert = .shared
                }
            }
        }
        parent.present(shareSheet, animated: true, completion: nil)
    }
}
