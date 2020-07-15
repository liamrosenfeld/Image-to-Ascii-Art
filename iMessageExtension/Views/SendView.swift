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
                        Image(systemName: "arrow.counterclockwise")
                            .font(Font.title3.bold())
                            .foregroundColor(.white)
                            .padding(5)
                    })
                    .accessibility(value: Text("New Image"))
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
                    .accessibility(value: Text("Send"))
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
        }.alert(item: $alert) { alert in
            switch alert {
            case .noAscii:
                return Alert(
                    title: Text("Whoah There!"),
                    message: Text("The ASCII Art must download before it can be shared.")
                )
            case .uploadError:
                return Alert(
                    title: Text("ASCII Art Could Not Be Uploaded"),
                    message: Text("Please check your internet connection.")
                )
            }
        }
    }
    
    // MARK: - Send Message
    
    let database = CKContainer(identifier: "iCloud.com.liamrosenfeld.ImageToAsciiArt").publicCloudDatabase
    
    func sendMessage(asciiArt: String) {
        // generate preview image
        let maxImageSize = CGSize(width: 500, height: 500)
        let image = asciiArt.toImage(withFont: asciiFont).imageConstrainedToMaxSize(maxImageSize)
        
        let message = makeMessage(asciiArt: asciiArt, image: image)
        
        saveToDatabase(asciiArt: asciiArt) { result in
            switch result {
            case .success(let id):
                message.url = self.makeMessageURL(dbID: id)
                
                delegate.message = message
                
            case .failure(let err):
                alert = .uploadError
                print("Upload error: \(err)")
            }
        }
    }
    
    func saveToDatabase(asciiArt: String, completion: @escaping (Result<String, Error>) -> Void) {
        let asciiRecord = CKRecord(recordType: "AsciiArt")
        asciiRecord["text"] = asciiArt as NSString
        
        database.save(asciiRecord) { (record, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                if let record = record {
                    completion(.success(record.recordID.recordName))
                }
            }
        }
        
    }
    
    func makeMessage(asciiArt: String, image: UIImage) -> MSMessage {
        let session = MSSession()
        let message = MSMessage(session: session)
        let layout = MSMessageTemplateLayout()
        layout.image = image
        layout.caption = "Ascii Art"
        message.layout = layout
        return message
    }
    
    func makeMessageURL(dbID: String) -> URL {
        var components = URLComponents()
        let qID = URLQueryItem(name: "dbID", value: dbID )
        components.queryItems = [qID]
        return components.url!
    }
}
