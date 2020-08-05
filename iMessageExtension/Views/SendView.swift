//
//  SendView.swift
//  Image To Ascii Art
//
//  Created by Liam Rosenfeld on 7/12/20.
//  Copyright © 2020 Liam Rosenfeld. All rights reserved.
//

import SwiftUI
import Combine
import UIKit
import Messages
import CloudKit

class SendDelegate: ObservableObject {
    
    var sendMessage = PassthroughSubject<SendDelegate, Never>()
    
    var message: MSMessage = MSMessage() {
        didSet {
            sendMessage.send(self)
        }
    }
}

struct SendView: View {
    
    enum AlertType: Identifiable {
        case noAscii
        case uploadError
        
        var id: AlertType { self }
    }
    
    // Connection to the outside
    let mode: InputMode
    @ObservedObject var delegate: SendDelegate
    
    // Internal ascii stuff
    @State private var image: UIImage?
    @State private var ascii: String?
    
    // Showing UI State
    @State private var alert: AlertType? = nil
    @State private var showingImageGetter  = true
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        showingImageGetter = true
                    }, label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(Font.title3.bold())
                            .foregroundColor(.white)
                            .padding(5)
                    })
                    .accessibility(label: Text("New Image"))
                    .padding(.leading, 10)
                    
                    Spacer()
                    
                    Button(action: {
                        if let ascii = ascii {
                            sendMessage(asciiArt: ascii)
                        } else {
                            alert = .noAscii
                        }
                    }, label: {
                        Image(systemName: "paperplane")
                            .font(Font.title3.bold())
                            .foregroundColor(.white)
                            .padding(5)
                    })
                    .accessibility(label: Text("Send"))
                    .padding(.trailing, 10)
                }.frame(minWidth: 0, maxWidth: .infinity).padding(10).background(Color.navBar)
                
                
                if let ascii = ascii {
                    GeometryReader { proxy in
                        ZoomableText(text: ascii, frame: proxy.frame(in: .local))
                    }
                } else {
                    if image != nil {
                        VStack {
                            Spacer()
                            ProgressView("Converting")
                            Spacer()
                        }
                    } else {
                        Spacer()
                        Text("Please Select an Image")
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
            }
        }.sheet(isPresented: $showingImageGetter) {
            switch mode {
            case .pick:
                PhotoPickerView(image: $image)
            case .take:
                CameraView(image: $image)
            case .none: // on just swipe up, default to pick
                PhotoPickerView(image: $image)
            }
        }
        .alert(item: $alert, content: matchAlert)
        .onChange(of: image, perform: convertImage)
    }
    
    func matchAlert(alert: AlertType) -> Alert {
        switch alert {
        case .noAscii:
            return Alert(
                title: Text("Whoah There!"),
                message: Text("ASCII Art must generate before it can be sent.")
            )
        case .uploadError:
            return Alert(
                title: Text("ASCII Art Could Not Be Uploaded"),
                message: Text("Please check your internet connection.")
            )
        }
    }
    
    func convertImage(image: UIImage?) {
        ascii = nil
        
        guard let image = image else {
            return
        }
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            let asciiArt = AsciiArtist.createAsciiArt(image: image)
            DispatchQueue.main.async {
                ascii = asciiArt
            }
        }
    }
    
    func sendMessage(asciiArt: String) {
        MSMessage.messageFromAscii(asciiArt, font: AsciiArtist.font) { result in
            switch result {
            case .success(let message):
                delegate.message = message
            case .failure(let err):
                alert = .uploadError
                print("Upload error: \(err)")
            }
        }
    }
}
