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

class SendDelegate: ObservableObject {
    
    var sendAscii = PassthroughSubject<SendDelegate, Never>()
    
    var asciiToSend: String = "" {
        didSet {
            sendAscii.send(self)
        }
    }
}

struct SendView: View {
    // Connection to the outside
    let mode: InputMode
    @ObservedObject var delegate: SendDelegate
    
    // Internal ascii stuff
    @State private var image: UIImage?
    @State private var ascii: String?
    
    // Showing UI State
    @State private var showingNoAsciiAlert = false
    @State private var showingImageGetter  = true
    
    let asciiFont = UIFont(name: "Menlo", size: 7)!
    
    var body: some View {
        ZStack {
            Color.background
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        showingImageGetter = true
                    }, label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("New")
                        }
                        .foregroundColor(.white)
                        .padding(5)
                    })
                    .padding(.leading, 10)
                    
                    Spacer()
                    
                    Button(action: {
                        if let ascii = ascii {
                            delegate.asciiToSend = ascii
                        } else {
                            showingNoAsciiAlert = true
                        }
                    }, label: {
                        HStack {
                            Image(systemName: "paperplane")
                            Text("Send")
                        }
                        .foregroundColor(.white)
                        .padding(5)
                    })
                    .padding(.trailing, 10)
                    .alert(isPresented: $showingNoAsciiAlert) {
                        Alert(title: Text("Whoah There!"), message: Text("You have to create some ascii art before you can share it."))
                    }
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
        }.onChange(of: image) { (image) in
            ascii = nil
            
            guard let image = image else {
                return
            }
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                let asciiArt = AsciiArtist.createAsciiArt(image: image, font: asciiFont)
                DispatchQueue.main.async {
                    ascii = asciiArt
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
    }
}
